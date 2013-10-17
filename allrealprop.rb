require 'rubygems'
require 'mechanize'

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
  
  ownername= table.xpath('./tr[2]/td[2]').text
  street = table.xpath('./tr[6]/td[2]').text
  citystate = table.xpath('./tr[7]/td[2]').text
  zip = table.xpath('./tr[8]/td[2]').text

  info={'ownername' => ownername,
    'street' => street,
    'city/state' => citystate,
    'zip' => zip,
    }
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
      puts owner
    end
    prior_group=next_group
    next_group=result.link_with(:href=>'property_info_results_next.asp').click
  end
  next_group.links_with(:text=>'Details').each do |link|
    owner=get_owner link.click.content
    owners.push owner
    puts owner
  end
  
  return owners
  
end

File.open(ARGV[0]).each_line do |line|
 street=line.split[0]
 puts "working street "+street
 get_houses_on_street street  
 sleep 0.3
end 

