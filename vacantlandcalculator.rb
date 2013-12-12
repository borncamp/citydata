#calculate total area of vacant land
require 'mongo'
include Mongo

dbread=MongoClient.new('localhost').db('citydata')
readcoll=dbread['realproperty']
value=0

readcoll.find('propertyclass'=> '311 RES VAC LAND').each do |row|
  area=0
  area=row['depth'].to_f*row['frontage'].to_f
  value+=area
end

puts value
