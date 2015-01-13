# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2004-2008 Jean Privat <jean@pryen.org>
#
# This file is free software, which comes along with NIT.  This software is
# distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without  even  the implied warranty of  MERCHANTABILITY or  FITNESS FOR A 
# PARTICULAR PURPOSE.  You can modify it is you want,  provided this header
# is kept unaltered, and a notification of the changes is added.
# You  are  allowed  to  redistribute it and sell it, alone or is a part of
# another product.

# Date manipulation
module date_f

#The main class Date
public class Date

private var years_In : Int 
private var mounth_In : Int
private var day_In : Int

private var hours_In : nullable Int = 0
private var min_In : nullable Int = 0
private var sec_In : nullable Int = 0

	#Return the with String type
	redef fun to_s do

	var y = years_In.to_s
	var m = mounth_In.to_s
	var d = day_In.to_s

	return y +"/"+ m +"/"+ d
	end
	
	#Compare two Date
	# forms : 1 for day, 2 for mounth, 3 for years
	fun date_diff( d2 : Date, forms : Int ) : Int do

		var y_Out  = 0
		var m_Out  = 0
		#var d_Out  = 0

		var out = 0

		if forms == 1 then 
			y_Out = years_In - d2.get_y
			y_Out = y_Out * 365

			m_Out = mounth_In - d2.get_m
			m_Out = m_Out * 30

			out = day_In - d2.get_d + m_Out + y_Out
			
	
		else if forms == 2 then
			y_Out = years_In - d2.get_y
			y_Out = y_Out * 12

			out = mounth_In - d2.get_m + y_Out
		end
		
		return out

	end

	#equals: this function compare two date equality
	redef fun == (d)  do
		var x = false
		var local_date  = new Date (years_In, mounth_In, day_In)
		if d isa Date then
			if local_date.date_diff(d,1) == 0 then
		
				x = true
			end
		end
		return x
	end

	redef fun hash do

		return years_In + mounth_In * 1024 + day_In * 2048
	end

	#yearsOn: check if the date is in the interval
	fun years_on ( d1, d2 : Date ) : Bool do
		var x = false
		#Date (years_In, mounth_In, day_In)

		if d1.get_y - years_In != d2.get_y - years_In or (d1.get_y == years_In and d2.get_y == years_In) then
			x = true
		end

		return x
	end

	#mounth

	#Geters
	fun get_y : Int do
		return years_In
	end

	#Geters
	fun get_m : Int do
	         return mounth_In
	end

	#Geters
	fun get_d : Int do
		return day_In
	end


end
