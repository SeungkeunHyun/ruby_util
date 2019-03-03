# :category: Utilities, Modules
# Entry point of ruby util modules
# it imports all standard libraries 
# and configure logging options using utilcfg.json that can be extended
# for other modules to be configured in future
# All modules in this file needs to be placed under the same folder of this code
# modules in this utils are like below
# modules:: log, date, file, regx, csv
# classes:: parse_batch, IntuitionMaper

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

# :method: init logger object for this utility
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