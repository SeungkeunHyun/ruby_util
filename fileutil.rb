module FileUtil
	# deals with file I/O 
	module_function
	
	# read file with given encoding
	#
	# @note default encoding is utf-8
	#
	# @param path [String]
	#
	# @param encoding [String]
	#
	# @return [String] file content
	#
	def readfile(path, encoding = 'UTF-8')
		filecontent = File.open(path, 'r:' + encoding, &:read)
		return filecontent
	end 

	# loads json from given file path
	#
	# @param path [String]
	#
	# @return [Hash] json object in Hash
	#
	def loadjson(path)
		jsonBody = File.read(path)
		return JSON.load(jsonBody)
	end

	# gets days of given path's last modified date
	#
	# @param path [String]
	#
	def fileage(path)
		mtime = File.mtime(path)
		LogUtil.debug('file modified at ', mtime)
		return Time.now - mtime
	end

	# checks whether given path's file is opened by other process
	#
	# @note can be used in checking file writing is done or not
	#
	# @param path [String]
	#
	def isinuse?(path)
		f = File.open(path, 'r')
		opened = f.closed?
		f.close
		return opened
	end

	# writes/appends a line to a given path
	#
	# @param line [String]
	#
	# @param path [String] file path to append
	#
	def writetofile(line, path)
		File.open(path, "a") { |file| file.puts line}
	end

	# gets lines of given path that matches key pattern
	#
	# @note used in multiple file mapping of given master file
	#
	# @param path [String] 
	#
	# @param keypat [String] regex expression to collect matching lines
	#
	# @return [String[]] matched lines of keypat
	#
	def getlinesofkey(path, keypat)
		lines = []
		File.readlines(path).each do |line|
			if line =~ /#{keypat}/
				lines << line.strip
			end
		end
		return lines
	end

	# gets header with given delimiter then returns matching rows as Hash
	#
	# @note it uses #getlinesofkey
	#
	# @param path [String] filepath
	#
	# @param keypat [String] key pattern of regex
	#
	# @delim delimiter of header line's column names (default is | )
	#
	# @return [Hash] matched records
	#
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

	# gets file list of given folder of file pattern
	#
	# @note (see #getrecordsofkey, #getlinesofkey)
	#
	# @param path [String] should be folder's path
	#
	# @param filepat [String] regex pattern of file to lookup
	#
	# @return [String[]] files matched filepat
	#
	def getfileoffolder(path, filepat)
		LogUtil.debug('file pattern to find', path + filepat)
		files = Dir.glob(path + filepat)
		if files.length > 0
			return files
		end
		return nil
	end

	# writes hash into pretty print versin of JSON to given path
	#
	# @param hashdat [Hash] hash data to be written into path
	#
	# @param path [String]
	def writejson(hashdat, path)
		File.write(path, JSON.pretty_generate(hashdat))
	end
end