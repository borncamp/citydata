require 'rubygems'
require 'mechanize'
require 'mongo'
include Mongo

dbread=MongoClient.new('localhost').db('citydata')
@readcoll=dbread['realproperty']

dbwrite=MongoClient.new('localhost').db('citydata')
@writecoll=dbwrite['citysales']

agent=Mechanize.new

@readcoll.find.each do |row|
  sales=[]
  location=row['propertylocation'].split()
  number=location.shift
  street=location.join ' '
  puts "street "+street+ "number "+number
  page=agent.get 'http://www.city-buffalo.com/applications/propertyinformation/default.aspx'
  
  searchForm=page.form_with :name=>'Form1'
  streetField=searchForm.field_with :name=>'Propsearch:txtStreet'
  numberField=searchForm.field_with :name=>'Propsearch:txtHsn'
  
  streetField.value=street
  numberField.value=number
  
  listings=searchForm.click_button searchForm.buttons[0]
  listingViewForm=listings.form_with :name=> 'Form1'
  targetField=listingViewForm.field_with :name=> '__EVENTTARGET'
  targetField.value='Searchdetails:dgListProp:_ctl3:lnkView'
  
  propListing=listingViewForm.submit
  propSalesForm=propListing.form_with :name=>'Form1'
  targetField=propSalesForm.field_with :name=> '__EVENTTARGET'
  targetField.value='Ownerdetails:lnkSales'
  
  salesListing=propSalesForm.submit
  noko=Nokogiri::HTML salesListing.content
  infoTable=noko.css('table#Table1')
  saleTables=infoTable.search('table')[2..-2]
  saleTables.each do |sale| 
    record={
       'deedate'=>sale.xpath('//tr[2]/td[1]').children[0].to_s.strip,
       'deedbook'=>sale.xpath('//tr[2]/td[2]').children[0].to_s,
       'deedpage'=>sale.xpath('//tr[2]/td[3]').children[0].to_s,
       'deedtype'=>sale.xpath('//tr[2]/td[4]').children[0].to_s,
       'validsale'=>sale.xpath('//tr[2]/td[5]').children[0].to_s,
       #secondrow,
       'saleprice'=>sale.xpath('//tr[4]/td[1]').children[0].to_s,
       'salecondition'=>sale.xpath('//tr[4]/td[2]').children[0].to_s,
       'parcelno'=>sale.xpath('//tr[4]/td[3]').children[0].to_s
    }
    sales.push record
  end
  data=[:sbl=>row['sbl'], :location=>number+" "+street, :sales=>sales]
  @writecoll.insert data
end
     

