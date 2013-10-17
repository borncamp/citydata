require 'rubygems'
require 'mechanize'
require 'mongo'
include Mongo

db=MongoClient.new('localhost').db('citydata')
@coll=db['realproperty']

agent=Mechanize.new
page=agent.get "https://paytax.erie.gov/webprop/index.asp"
@search_form=page.form_with :action=>"property_info_results.asp"


def get_details number,street
  @search_form.txtnum=number
  @search_form.txtstreet=street
  @search_form.Juris="1402"
  result=@search_form.submit
  details=result.link.click.content
end

def get_owner details
  noko=Nokogiri::HTML(details)
  table=noko.xpath "/html/body/div[@id='container']/div[@id='center_column_wide']/table[@id='generic_site_table']"
 
  #shit about house
  info={
    "parcelstatus" => table.xpath('./tr[1]/td[1]').text,
    "sbl" => table.xpath('./tr[2]/td[1]').text,
    "propertylocation" => table.xpath('./tr[3]/td[1]').text,
    "propertyclass" => table.xpath('./tr[4]/td[1]').text,
    "assessment" => table.xpath('./tr[5]/td[1]').text,
    "taxable" => table.xpath('./tr[6]/td[1]').text,
    "desc1" => table.xpath('./tr[7]/td[1]').text,
    "desc2" => table.xpath('./tr[8]/td[1]').text,
    "deedbook" => table.xpath('./tr[9]/td[1]').text,
    "frontage" => table.xpath('./tr[10]/td[1]').text,
    "yearbuilt" => table.xpath('./tr[11]/td[1]').text,
    "beds" => table.xpath('./tr[12]/td[1]').text,
    "fireplace" => table.xpath('./tr[13]/td[1]').text,

    #about the owner ,
    "ownername" => table.xpath('./tr[2]/td[2]').text,
    "mailingaddress" => table.xpath('./tr[3]/td[2]').text,
    "line2" => table.xpath('./tr[4]/td[2]').text,
    "line3" => table.xpath('./tr[5]/td[2]').text,
    "street" => table.xpath('./tr[6]/td[2]').text,
    "citystate" => table.xpath('./tr[7]/td[2]').text,
    "zip" => table.xpath('./tr[8]/td[2]').text,

    #shit about house,
    "deedpage" => table.xpath('./tr[9]/td[2]').text,
    "depth" => table.xpath('./tr[10]/td[2]').text,
    "squareft" => table.xpath('./tr[11]/td[2]').text,
    "baths" => table.xpath('./tr[12]/td[2]').text,
    "school" => table.xpath('./tr[13]/td[2]').text
  }

#  info={'ownername' => ownername,
#    'street' => street,
#    'city/state' => citystate,
#    'zip' => zip,
#    }
end

def get_houses_on_street street
  @search_form.txtstreet=street
  @search_form.Juris="1402"
  result=@search_form.submit
  prior_group=result
  next_group=result.link_with(:href=>'property_info_results_next.asp').click
  owners=[]
  
  while next_group.content != prior_group.content do
    prior_group.links_with(:text=>'Details').each do |link|
      owner=get_owner link.click.content
      owners.push owner
    end
    prior_group=next_group
    next_group=result.link_with(:href=>'property_info_results_next.asp').click
  end
  next_group.links_with(:text=>'Details').each do |link|
    owner=get_owner link.click.content
    owners.push owner
  end
  
  return owners
end

listings=[]
File.open(ARGV[0]).each_line do |line|
  puts 'working on street '+line
  street=line.split[0]
  listings=get_houses_on_street street
  listings.each do |listing|
    @coll.insert listing
  end

  sleep 0.3
end 

