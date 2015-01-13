import date

var test  = new Date.time(2014, 02, 09, 13, 50, 0)
var test2 = new Date.time(2014, 02, 09, 13, 51, 0)
var test3 = new Date(2014, 01, 12)
var res   = test.diff_month(test2)


print "ToString :" + test.to_s
print "Date diff : {res}"
print "Equale : {test == test3}"

print "Year On : {test3.years_on(test,test2)}"
print "Month On : {test3.month_on(test,test2)}"
