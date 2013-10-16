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

  city = table.xpath('./tr[1]/td[2]').text
  street = table.xpath('./tr[6]/td[2]').text
  citystate = table.xpath('./tr[7]/td[2]').text
  zip = table.xpath('./tr[8]/td[2]').text

  info={'city' => city,
    'street' => street,
    'city/state' => citystate,
    'zip' => zip,
    }
end

details=get_details '27','eighteenth'

owner=get_owner details
puts owner
