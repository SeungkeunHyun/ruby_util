require 'date'
require 'json'
require './logutil.rb'
require './dateutil.rb'

def readfile(path, encoding = 'UTF-8')
	filecontent = File.open(path, 'r:' + encoding, &:read)
	return filecontent
end 


def loadjson(path)
	jsonBody = File.read(path)
	return JSON.load(jsonBody)
end

def fileage(path)
	return Time.now - File.mtime(path)
end