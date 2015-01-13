import date_f

var test  = new Date(2014, 01, 09)
var test2 = new Date(2016, 01, 09)
var test3 = new Date(2015, 01, 12)
var res   = test.date_diff(test2,2)


print "ToString :" + test.to_s
print "Date diff : {res}"
print "Equale : {test == test2}"

print "Year On : {test3.years_on(test,test2)}"
