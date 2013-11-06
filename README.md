citydata
========

buffalo city data

My code looks like shit
My code runs like shit
Have a problem?
Make a commit

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

realproperty.json.zip - A zipped copy of the real property db scraped using allrealprop.rb in JSON format

realproperty.csv - A copy of the real property db scraped using allrealprop.rb in csv format

realproperty.csv.zip - A zipped copy of the real property db scraped using allrealprop.rb in csv format
