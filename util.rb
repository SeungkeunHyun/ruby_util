require 'date'
require 'json'
require 'logger'
require 'csv'
require_relative './logutil'
require_relative './dateutil'
require_relative './fileutil'
require_relative './regxutil'
require_relative './parse_batch'
require_relative './csvutil'
require_relative './IntuitionMapper'

def initLogger()
	config = FileUtil.loadjson(File.dirname(__FILE__) + '/utilcfg.json')
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
	LogUtil.setformatter
	LogUtil.setloglevel(config['log.level'])
end

initLogger()