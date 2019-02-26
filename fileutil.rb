def readfile(path, encoding = 'UTF-8')
	filecontent = File.open(path, 'r:' + encoding, &:read)
	return filecontent
end 


def loadjson(path)
	jsonBody = File.read(path)
	return JSON.load(jsonBody)
end

def fileage(path)
	mtime = File.mtime(path)
	debug('file modified at ', mtime)
	return Time.now - mtime
end

def isinuse(path)
	f = File.open(path, 'r')
	opened = f.closed?
	f.close
	return opened
end