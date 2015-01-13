# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Date manipulation
module date

# The main class Date (comming soon...)
#
# 	var d = new Date(2014, 01, 09)
# 	assert d.to_s == "2014/01/09"
#
class Date
	super Comparable

	# Years as an integer (Int) ex: 1989
	var year: Int

	# Months as an integer (Int) ex: "3" for March
	var month: Int

	# Days as an integer (Int)
	var days: Int

	# Hours as an integer (Int)
	var hours: Int = 0
	
	# Minutes as an integer (Int)
	var mint: Int = 0

	# Secound as an integer (Int)
	var sec: Int = 0

	# UTC time zone
	var t_zone = "Z"

	# for set the time (hours, min, sec) 
	init time(y, mth, d, h, m, s: Int) do
		year = y
		month = mth
		days = d
		hours = h
		mint = m
		sec = s
	end

	# this will initialized the current date and time
	init today do
		var tm = new Tm.localtime
		year = 1900 + tm.year
		month = tm.mon + 1
		days = tm.mday
		hours = tm.hour
		mint = tm.min
		sec = tm.sec
	end

	# date and time expressed according to ISO 8601
	redef fun to_s 
	do
		var y = year.to_s
		var m = month.to_s
		var d = days.to_s
		var h = hours.to_s
		var mth = month.to_s
		var s = sec.to_s

		return "{y}-{m}-{d} {h}:{mth}:{s}{t_zone}"
	end
	
	# Compare two Date and return the difference in days
	fun diff_days(d2: Date): Int 
	do
		var y_out  = 0
		var m_out  = 0
		var out = 0 

		y_out = year - d2.year
		y_out = y_out * 365
		m_out = month - d2.month
		m_out = m_out * 30
		out = days - d2.days + m_out + y_out

		return out
	end

	# Compare two date and retrun the difference in months
	fun diff_month(d2: Date): Int
	do
		var y_out = 0
		var out = 0

		y_out = year - d2.year
		y_out = y_out * 12
		out = month - d2.month + y_out

		return out
	end

	# Compare two date and return the difference in years
	fun diff_years(d2: Date): Int
	do
		return year - d2.year
	end



	# Is self equals to d ?
	redef fun ==(d)  
	do
		if d isa Date and self.diff_days(d) == 0 then
			if (hours * 3600 + mint * 60 + sec) != (d.hours * 3600 + d.mint * 60 + d.sec) then
				return false
			end
			return true
		end
		return false
	end

	# For the moment, the time is not supported
	redef fun <(d)
	do
		return d isa Date and self.diff_days(d) < 0
	end

	redef fun hash 
	do
		# the hash function must be review
		return year + month * 1024 + days * 2048
	end

	# Check if the date(self) is between the interval (for years)
	fun years_on(d1, d2: Date): Bool 
	do
		return (d1.year > year and d2.year < year) or (d2.year > year and d1.year < year) or (d1.year == year or d2.year == year)
	end

	# Check if the date(self) is between the interval (for month)
	fun month_on(d1, d2: Date) : Bool
	do
		if not self.years_on(d1,d2) then return false
		return (d1.month > month and d2.month < month) or (d2.month > month and d1.month < month) or (d1.month == month or d2.month == month)
	end

	# Check if the date(self) is between the interval (for days, the time is not supported for now)
	redef fun is_between(d1,d2)
	do
		if not (d1 isa Date) or not (d2 isa Date) then return false
		if not self.month_on(d1,d2) then return false
		return (d1.days > days and d2.days < days) or (d2.days > days and d1.days < days) or (d1.days == days or d2.days == days)
	end

end
