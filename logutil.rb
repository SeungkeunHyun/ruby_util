require 'logger'

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

def error_handler(err)
	(Thread.current[:errors] ||= []) << err
	error("#{err.class}: #{err.message}\n" + err.backtrace.join("\n"))
end