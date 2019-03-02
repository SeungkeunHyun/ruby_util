require 'date'
require 'json'
require_relative './logutil.rb'
require_relative './dateutil.rb'
require_relative './fileutil.rb'
require_relative './regxutil.rb'
require_relative './parse_batch.rb'

def initLogger()
	config = loadjson(File.dirname(__FILE__) + '/utilcfg.json')
	if config.key?('log.path')
		lpath = config['log.path']
		unless File.file?(lpath)
			dpath = lpath.gsub(/[^\/]+$/,'')
			Dir.mkdir(dpath) unless Dir.exist?(dpath)
		end
		if config.key?('log.interval')
			$logger = Logger.new(lpath, config['log.interval'])
		else
			$logger = Logger.new(lpath)
		end
	end
	setformatter
	setloglevel(config['log.level'])	
end

initLogger()