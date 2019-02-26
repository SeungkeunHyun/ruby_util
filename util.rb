require 'date'
require 'json'
require './logutil.rb'
require './dateutil.rb'
require './fileutil.rb'

def initLogger()
	config = loadjson('./utilcfg.json')
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