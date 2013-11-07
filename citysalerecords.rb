require 'mechanize'

agent=Mechanize.new

page=agent.get 'http://www.city-buffalo.com/applications/propertyinformation/default.aspx'

searchForm=page.form_with :name=>'Form1'
streetField=searchForm.field_with :name=>'Propsearch:txtStreet'
numberField=searchForm.field_with :name=>'Propsearch:txtHsn'

streetField.value='paderewski'
numberField.value='186'

listings=searchForm.click_button searchForm.buttons[0]
listingViewForm=listings.form_with :name=> 'Form1'
targetField=listingViewForm.field_with :name=> '__EVENTTARGET'
targetField.value='Searchdetails:dgListProp:_ctl3:lnkView'

propListing=listingViewForm.submit
propSalesForm=propListing.form_with :name=>'Form1'
targetField=propSalesForm.field_with :name=> '__EVENTTARGET'
targetField.value='Ownerdetails:lnkSales'

salesListing=propSalesForm.submit

puts  listings.content
