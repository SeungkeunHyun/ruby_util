module FileUtil
	module_function
	
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

	def writetofile(line, path)
		File.open(path, "a") { |file| file.puts line}
	end

	def getlinesofkey(path, keypat)
		lines = []
		File.readlines(path).each do |line|
			if line =~ /#{keypat}/
				lines << line.strip
			end
		end
		return lines
	end

	def getrecordsofkey(path, keypat, delim = '|')
		header = File.foreach(path).first.strip
		fields = header.split(delim)
		lines = getlinesofkey(path, keypat)
		lines_dic = []
		lines.each do |line|
			line_dic = {}
			line = line.gsub(/[#{delim}]+$/,'')
			data = line.split(delim)
			fields.each do |f|
				line_dic[f] = data.shift()
			end
			lines_dic << line_dic
		end
		return lines_dic
	end

	def getfileoffolder(path, filepat)
		debug('file pattern to find', path + filepat)
		files = Dir.glob(path + filepat)
		if files.length > 0
			return files
		end
		return nil
	end

	def writejson(hashdat, path)
		File.write(path, JSON.pretty_generate(hashdat))
	end
end