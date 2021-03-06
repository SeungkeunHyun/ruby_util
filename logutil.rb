module LogUtil
	# sub utility for Logger
	module_function
	
	# global variable to be used/configured (see #initLogger)
	$logger = nil
	# log levels to be used in a lookup of current log level using index of each level
	$loglevels = ['debug', 'info', 'warn', 'error', 'fatal']
	if defined?(logging)
		$logger = logging
	else
		$logger = Logger.new(STDOUT)
		$logger.level = Logger::DEBUG
	end

	# formats logger's printing
	def setformatter()
		$logger.formatter = proc do |severity, datetime, progname, msg|
			date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
			if severity == "INFO" or severity == "WARN"
				"[#{date_format}] #{severity}  (#{progname}): #{msg}\n"
			else
				"[#{date_format}] #{severity} (#{progname}): #{msg}\n"
			end
		end
	end

	# set logger's level to be printed 
	# @note lower level would be ignored (see #loglevels)
	def setloglevel(lvl)
		prevlevel = $logger.level
		if prevlevel == $loglevels.index(lvl)
			info("Log level kept as #{$loglevels[prevlevel].upcase}")
		else
			$logger.level = $loglevels.index(lvl)
			info("Log level changed from #{$loglevels[prevlevel].upcase} to #{lvl.upcase}")
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

	def warn(*args)
		ref = caller_locations(1,1)[0].label
		log(ref, Logger::WARN, args)
	end

	def error(*args)
		depth = caller_locations.length
		ref = caller_locations(depth-1,1)[0].label
		log(ref, Logger::ERROR, args)
	end

	def fatal(*args)
		ref = caller_locations(1,1)[0].label
		log(ref, Logger::FATAL, args)
	end

	# main log writer called by methods for each log level
	#
	# it gets loglevel (one of #loglevels) and object array to be written to file
	#
	# any hash object would be printed into STDOUT to be shown as pretty JSON
	#
	# @note shouldn't be called directly from outside (see #debug, #info, #warn, #error, #fatal)
	#
	def log(*args)
		ref = args.shift()
		level = args.shift()
		$logger.progname = ref	
		args[0].map! { |arg|
			case arg
				when Array
					if arg[0].class == Hash
						puts(JSON.pretty_generate(arg))
						arg = arg
					else
						arg = arg
					end
				when Hash
					puts(JSON.pretty_generate(arg))
					arg = arg
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

	# handles error to be catched within begin rescure block
	def error_handler(err)
		(Thread.current[:errors] ||= []) << err
		error("#{err.class}: #{err.message} " + err.backtrace.join(","))
	end

	# any exit with error would be printed as fatal as a exit hook
	at_exit do
		if $!
			fatal("#{$!} at #{$@}")
		end
	end
end