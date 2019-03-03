module RegxUtil
	# regular expression utility module (to be extended, added method definitely)
	module_function 
	
	# check obj is integer or not
	#
	# @param obj [Object]
	def is_integer?(obj)
		if obj
			return obj.to_s == obj.to_i.to_s
		end
		return false
	end
	
	# check obj is a float or not (see @is_integer?)
	def is_float?(obj)
		if obj
			return obj.to_s == obj.to_f.to_s
		end
		return false
	end

	# check obj is an email address or not
	def is_email?(obj)
		if obj
			if obj =~ URI::MailTo::EMAIL_REGEXP
				return true
			end
		end 
		return false
	end

	# casts obj into one of integer, float or itself 
	#
	# @note uses #is_integer? and #is_float?
	def trycast(obj)
		if obj
			return is_integer?(obj) ? obj.to_i : is_float?(obj) ? obj.to_f : obj
		end
		return obj
	end

	# removes any non digit from obj
	def tobeint(obj)
		if obj 
			return obj.to_s.gsub(/\D/,'').to_i
		end
		return obj
	end

	# removes all non digit and formats with 2 digits next to dot
	def tobeamount(obj)
		if obj.to_s =~ /(\d+)([.]\d{1,2})?/
			amt = $1 + ($2 || '.00')
			return amt.to_f
		end
		return nil
	end

	# removes any white space in obj
	def tobenospace(obj)
		obj.to_s.gsub(/\s/,'')
	end

	# removes any special characters are not alpha-numeric
	def tobealphanum(obj)
		obj.to_s.gsub(/\W/,'')
	end

	# splits obj with given delimiter after removing trailing empty delimiters
	def getfields(obj, delim)
		obj.to_s.strip.gsub(/[#{delim}]+$/, '').split(delim)
	end

	# genreates hash array with given obj (split by delimiter) and header fields
	def makehash(obj, delim, fields)
		LogUtil.debug(obj, delim, fields)
		fds = obj.to_s.strip.split(delim)
		hashrec = {}
		fields.each do |field|
			hashrec[field] = fds.shift()
		end
		return hashrec
	end
end