require 'date'
require 'logger'
require 'json'

$logger = nil
if defined?(logging)
	$logger = logging
else
	$logger = Logger.new(STDOUT)
	level = Logger::DEBUG
end
$logger.formatter = proc do |severity, datetime, progname, msg|
    date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
    if severity == "INFO" or severity == "WARN"
        "[#{date_format}] #{severity}  (#{progname}): #{msg}\n"
    else
        "[#{date_format}] #{severity} (#{progname}): #{msg}\n"
    end
end

def debug(*args)
	ref = caller_locations(1,1)[0].label
	log(ref, Logger::DEBUG, args)
end

def info(*args)
	ref = caller_locations(1,1)[0].label
	log(ref, Logger::INFO, args)
end

def info(*args)
	ref = caller_locations(1,1)[0].label
	log(ref, Logger::INFO, args)
end

def warn(*args)
	ref = caller_locations(1,1)[0].label
	log(ref, Logger::WARN, args)
end

def error(*args)
	ref = caller_locations(1,1)[0].label
	log(ref, Logger::ERROR, args)
end

def fatal(*args)
	ref = caller_locations(1,1)[0].label
	log(ref, Logger::FATAL, args)
end


def log(*args)
	ref = args.shift()
	level = args.shift()
	$logger.progname = ref	
	args[0].map! { |arg|
		case arg
			when Array
				if arg[0].class == Hash
					JSON.pretty_generate(arg)
				else
					arg
				end
			when Hash
				puts(JSON.pretty_generate(arg))
				nil
			else
				arg = arg
		end
	}
	args = args[0].compact
	case level
		when Logger::DEBUG
			$logger.debug(args)
		when Logger::INFO
			$logger.info(args)
		when Logger::WARN
			$logger.warn(args)
		when Logger::ERROR
			$logger.error(args)
		when Logger::FATAL
			$logger.fatal(args)
	end
end

def readfile(path, encoding = 'UTF-8')
	filecontent = File.open(path, 'r:' + encoding, &:read)
	return filecontent
end 

def parsedate(strdt)
	if(strdt == nil || strdt.class != String)
		return strdt
	end
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
		when /\D{3}\s?\d{1,2},\s?(\d{2,4})/
			strdt = strdt.gsub(/\s/,'')
			if($1.length == 2)
				pat = '%b%d,%y'
			else
				pat = '%b%d,%Y'
			end
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

def loadjson(path)
	jsonBody = File.read(path)
	return JSON.load(jsonBody)
end