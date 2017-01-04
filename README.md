citydata
========

buffalo city data

Mostly defunct. No guarantees

realpropsearch.rb

    Takes a csv file that has a street number and name on each line
    Goes through that file and determines who owns that property and where they live
    This is useful for finding rental apartments and out of state landowners

    usage: ruby realpropsearch.rb Inrem47.csv

    has a default rate limit of 2 requests per second

allrealprop.rb

    Takes a file that lists street names
    goes through erie county web form and gets every house on the street
    the file 'streets' has a listing of every street in Buffalo

    usage: ruby allrealprop.rb streets

countysalerecords.rb
    
    Parses a mongodb for sbl number, then uses those numbers to
    lookup sale records for a given property on the counties website
    only ran on data for city of buffalo.  Ran on the realproperty.json
    dataset.

citysalerecords.rb

    Goes through mongodb collection and uses addresses to find sale
    records on the city of buffalo's property information dataset.
    Ran on the realproperty.json dataset.

flipper.rb
   Goes through mongodb collection and searches for sbl's that were 
   purchased as a tax sale and had another sale within 6 months of the
   deed date for 120% or more of the original sale price.

realproperty.json.zip - A zipped copy of the real property db scraped using allrealprop.rb in JSON format

realproperty.csv - A copy of the real property db scraped using allrealprop.rb in csv format

realproperty.csv.zip - A zipped copy of the real property db scraped using allrealprop.rb in csv format

citysales.json - A copy of the city of buffalo's sale history (Records seem to have a cutoff period in early 90's)

citysales.csv - A copy of citysales.json in csv format

citysalesshort.csv - A copy of citysales.csv with fields for sbl,location,saletype,saledate,saleprice






[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/borncamp/citydata/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
