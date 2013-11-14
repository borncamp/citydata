require 'rubygems'
require 'mechanize'
require 'mongo'
include Mongo

dbread=MongoClient.new('localhost',:pool_size=>10).db('citydata')
@readcoll=dbread['realproperty']

dbwrite=MongoClient.new('localhost',:pool_size=>20,:pool_timeout=>500).db('citydata')
@writecoll=dbwrite['citysales']


def getSales(row)
  sleep 1
  agent=Mechanize.new
  #$stdout.print 'I am a thread'
  begin
    location=row['propertylocation'].split()
    number=location.shift
    street=location.join ' '
     
    #$stdout.print "street "+street+ "number "+number
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
    if noko.content.index 'No Sales data found, please return to property listing.'
      #$stdout.print 'No Sale Data Found'
      data=[:sbl=>row['sbl'], :location=>number+" "+street, :sales=>['no sales data found']]
      @writecoll.insert data
      return
    end
     
    infoTable=noko.css('table#Table1')
    saleTables=infoTable.search('table')[2..-2]
    #$stdout.print "table count "+ saleTables.count().to_s
    sales=[]
    saleTables.each do |sale| 
      record=Hash.new
      record={
         'deedate'=>sale.xpath('./tr[2]/td[1]').children[0].to_s.strip,
         'deedbook'=>sale.xpath('./tr[2]/td[2]').children[0].to_s,
         'deedpage'=>sale.xpath('./tr[2]/td[3]').children[0].to_s,
         'deedtype'=>sale.xpath('./tr[2]/td[4]').children[0].to_s,
         'validsale'=>sale.xpath('./tr[2]/td[5]').children[0].to_s,
         #secondrow,
         'saleprice'=>sale.xpath('./tr[4]/td[1]').children[0].to_s,
         'salecondition'=>sale.xpath('./tr[4]/td[2]').children[0].to_s,
         'parcelno'=>sale.xpath('./tr[4]/td[3]').children[0].to_s
      }
      sales.push record
    end
    #total hack I know. don't feel like debugging
    #single sale records get duplicates in here
    #sales=sales.to_set.to_a
    #sales.uniq!
    data=[:sbl=>row['sbl'], :location=>number+" "+street, :sales=>sales]
    @writecoll.insert data
  rescue Exception => e
    $stderr.print 'threw an exception'+e.to_s
    data=[:sbl=>row['sbl'], :location=>number+" "+street, :sales=>['error processing']]
    @writecoll.insert data
  end
end
     
@readcoll.find.each do |row|
  sales=[]
  if @writecoll.find_one({:sbl=>row['sbl']})
    puts 'skipping '+ row['propertylocation'].to_s
    next
  end
  #be careful threading! city wbesite not that great at high load
  #puts Thread.new{getSales(row)}
  puts row['propertylocation'].to_s
  getSales(row)
#  puts 'new thread'+row['propertylocation'].to_s
end
