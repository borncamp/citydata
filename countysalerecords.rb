require 'rubygems'
require 'mechanize'
require 'mongo'
include Mongo

dbread=MongoClient.new('localhost').db('citydata')
@readcoll=dbread['realproperty']

dbwrite=MongoClient.new('localhost').db('citydata')
@writecoll=dbwrite['sales']

@agent=Mechanize.new


@readcoll.find.each do |row|
  sales=[]
  sbl=row['sbl'].split('-')
  sbl[0]=(format("%.5f", sbl[0].to_f/1000).to_s[2..-1])
  sbl[1]=format("%.5f", sbl[1].to_f/100000)[2..-1]
  sbl[2]=(format("%.6f",sbl[2].to_f/1000))[2..-1]
  sblkey='140200'+sbl.join
  page=@agent.get "http://paytax.erie.gov/webprop/property_info_history.asp?sblkey="+sblkey
  puts sblkey
  html=page.content
  #sometimes the sales don't have a valid table because the onwer is missing on a record
  #this leads to a missing <tr> tag for that row
  html.gsub! '</tr><th>Book', '</tr><tr><th>Book'
  noko=Nokogiri::HTML(html)
    
  table=noko.xpath "/html/body/div[@id='center_column_wide']/table[@id='generic_site_table']"

  table.search('tr').each do |tr|
    name=tr.children.search('td')[0].content
    #sometimes there is no name on a sale and the bookdate
    #gets shifted over into the first column
    begin
      bookdate=tr.children.search('td')[1].content
    rescue
      bookdate=name
      name="NULL"
    end
     
    sales.push([name,bookdate])
  end
  sbl=row['sbl']
  data=[:sbl=> sbl, :sblkey=>sblkey, :sales=> sales]
  @writecoll.insert data
end
