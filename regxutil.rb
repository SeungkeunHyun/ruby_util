def is_integer?(obj)
	if obj
		return obj.to_s == obj.to_i.to_s
	end
	return false
end

def is_float?(obj)
	if obj
		return obj.to_s == obj.to_f.to_s
	end
	return false
end

def trycast(obj)
	if obj
		return is_integer?(obj) ? obj.to_i : is_float?(obj) ? obj.to_f : obj
	end
	return obj
end

def tobeint(obj)
	if obj 
		return obj.to_s.gsub(/\D/,'').to_i
	end
	return obj
end

def tobeamount(obj)
	if obj.to_s =~ /(\d+)([.]\d{1,2})?/
		amt = $1 + ($2 || '.00')
		return amt.to_f
	end
	return nil
end

def tobenospace(obj)
	obj.to_s.gsub(/\s/,'')
end

def tobealphanum(obj)
	obj.to_s.gsub(/\W/,'')
end

def tobenonspace(obj)
	obj.to_s.gsub(/\s/,'')
end