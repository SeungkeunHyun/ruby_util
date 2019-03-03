module DateUtil
	# Handles, generates date object from/to string with various formats
	module_function 

	# parses date from string 
	#
	# supported format dd-mm-yyyy or yy, dd-MMM-yyyy or yy, yyyy-mm-dd
	#
	# Other format than above would return null(nil)
	#
	# @note any parameter isn't a [String] to be returned as it is.
	#
	# @param strdt [String] string to be parsed into date object
	#
	# @return [Date] parsed object or null(nil)
	#
	def parsedate(strdt)
		if(strdt == nil || strdt.class != String)
			return strdt
		end
		strdt = strdt.strip
		case strdt
			when /^\d{1,2}\D?\d{1,2}\D?(\d{2,4})$/
				if($1.length == 2)
					pat = '%d-%m-%y'
				else
					pat = '%d-%m-%Y'
				end
				strdt = strdt.gsub(/\D/,'-')
				LogUtil.debug('found '+ pat, strdt)
				return Date.strptime(strdt, pat)
			when /^\D{3}\s?\d{1,2},\s?(\d{2,4})$/
				if($1.length == 2)
					pat = '%b%d,%y'
				else
					pat = '%b%d,%Y'
				end
				strdt = strdt.gsub(/\s/,'')			
				LogUtil.debug('found ' + pat + ', ' + strdt)
				return Date.strptime(strdt, pat)
			when /[A-z]{3}\D\d{1,2}\D(\d{2,4})/
				if($1.length == 2)
					pat = '%b-%d-%y'
				else
					pat = '%b-%d-%Y'
				end
				LogUtil.debug('found ' + pat + ', ' + strdt)
				strdt = strdt.gsub(/\W/,'-')
				return Date.strptime(strdt, pat)
			when /\d{1,2}\W[A-z]{3}\W(\d{2,4})/
				if($1.length == 2)
					pat = '%d-%b-%y'
				else
					pat = '%d-%b-%Y'
				end
				LogUtil.debug('found ' + pat + ', ' + strdt)
				strdt = strdt.gsub(/\W/,'-')
				return Date.strptime(strdt, pat)
			when /\d{4}\W\d{1,2}\W\d{1,2}/
				LogUtil.debug('found %Y-%m-%d' + ', ' + strdt)
				strdt = strdt.gsub(/\W/,'-')
				return Date.strptime(strdt, '%Y-%m-%d')
			else
				LogUtil.debug('not defined: ' + strdt)
		end
		return nil
	end

	# generates sample date of birth for a test data
	#
	# @return [Date] random date between 1960 and 2000
	def generaterandomdob()
		return rand(Date.civil(1960, 1, 1)..Date.civil(2000, 12, 31))
	end

	# genrerates current time's in millisecond similar to javascript's new Date().getTime()
	#
	# @return [String] current millisecond since 1970-1-1
	def generatetimeinms()
		return DateTime.now.strftime('%Q')
	end

	# generates random date between 100 days ago and now for testing purpose
	#
	# @return [Date] 
	def generatedatelately()
		return rand((DateTime.now - 100)..DateTime.now)
	end

	# get age of given
	def getage(dob)
		dtbirth = parsedate(dob)
		age = Date.today.year - dtbirth.year
		if Date.today.yday < dtbirth.yday
			age -= 1
		end
		return age
	end

	# gets 2 parameters in array then gets days of difference of both
	#
	# @note any string parameter would be parsed into date first
	#
	# @param list of dates with a comma (see #parsedate)
	#
	# @return [Integer] days between 2 dates
	#
	def diffdate(*args)
		if args.length != 2
			LogUtil.info('Usage: 2 dates in date or string required')
		end
		dts = []
		args.each do |dt|
			if dt.class == String
				dts << parsedate(dt)
			else
				dts << dt
			end
		end
		(dt1, dt2) = dts.sort()
		dtdiff = dt2 - dt1
		return dtdiff.to_i
	end

	# gets days of given date from now
	#
	# @note it uses #diffdate
	#
	# @param odate [String] or [Date] to get days diff from now
	#
	# @return [Integer] days from now
	def daysaway(odate)
		return diffdate(Date.today, odate)
	end

	# get hours from given millisecond
	#
	# @param tm [String] or [Integer] 
	#
	# @return [Integer] hours of given ms floored
	def timeashour(tm)
		return tm.to_i / 3600
	end

	# gets days from given millisecond
	#
	# @note uses #timeashour
	#
	# @param tm [String] or [Integer]
	#
	# return [Integer] days of given ms floored
	def timeasday(tm)
		return timeashour(tm) / 24
	end
end