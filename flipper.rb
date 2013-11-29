#Find wonderful dolphins
require 'mongo'
include Mongo
require 'date'

dbread=MongoClient.new('localhost').db('citydata')
readcoll=dbread['citysales']

puts "can we do it?"
readcoll.find('sales'=> {'$elemMatch'=>{'deedtype'=> "T- Tax Sale"}}).each do |row|
#readcoll.find().each do |row|
  row['sales'].each.with_index do |sale, idx|
    if row['sales'][idx+1].nil?
      next
    end
    currentSaleDate=Date.strptime(sale['deedate'][0..9], '%m/%d/%Y')
    nextSaleDate=Date.strptime row['sales'][idx+1]['deedate'][0..9],'%m/%d/%Y'
    

    currentSalePrice=sale['saleprice'][1..-1].to_f
    nextSalePrice=row['sales'][idx+1]['saleprice'][1..-1].to_f
    

    if currentSalePrice*1.20<nextSalePrice and nextSaleDate-currentSaleDate<180 and sale['deedtype']=='T- Tax Sale'
      puts "eek Eeek Eeek!"+row['sbl']
    end
  end
end
