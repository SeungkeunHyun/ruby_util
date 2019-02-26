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
			debug('found '+ pat, strdt)
			return Date.strptime(strdt, pat)
		when /^\D{3}\s?\d{1,2},\s?(\d{2,4})$/
			if($1.length == 2)
				pat = '%b%d,%y'
			else
				pat = '%b%d,%Y'
			end
			strdt = strdt.gsub(/\s/,'')			
			debug('found ' + pat + ', ' + strdt)
			return Date.strptime(strdt, pat)
		when /[A-z]{3}\D\d{1,2}\D(\d{2,4})/
			if($1.length == 2)
				pat = '%b-%d-%y'
			else
				pat = '%b-%d-%Y'
			end
			debug('found ' + pat + ', ' + strdt)
			strdt = strdt.gsub(/\W/,'-')
			return Date.strptime(strdt, pat)
		when /\d{1,2}\W[A-z]{3}\W(\d{2,4})/
			if($1.length == 2)
				pat = '%d-%b-%y'
			else
				pat = '%d-%b-%Y'
			end
			debug('found ' + pat + ', ' + strdt)
			strdt = strdt.gsub(/\W/,'-')
			return Date.strptime(strdt, pat)
		when /\d{4}\W\d{1,2}\W\d{1,2}/
			debug('found %Y-%m-%d' + ', ' + strdt)
			strdt = strdt.gsub(/\W/,'-')
			return Date.strptime(strdt, '%Y-%m-%d')
		else
			debug('not defined: ' + strdt)
	end
	return nil
end

def getage(dob)
	dtbirth = parsedate(dob)
	age = Date.today.year - dtbirth.year
	if Date.today.yday < dtbirth.yday
		age -= 1
	end
	return age
end

def diffdate(*args)
	if args.length != 2
		info('Usage: 2 dates in date or string required')
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

def daysaway(odate)
	return diffdate(Date.today, odate)
end