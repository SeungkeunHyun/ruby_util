module TestUtils
	# Tests methods while developing utility files and classes
	module_function

	require './util.rb'
	require './spec/robot'

	def test_parsedate() 
		dt = parsedate('Feb/26/19')
		debug(dt)

		dt = parsedate('26/Feb/19')
		debug(dt)

		dt = parsedate('Feb/26/1999')
		debug(dt)

		dt = parsedate('26/Feb/1980')
		debug(dt)

		dt = parsedate('2019-2-26')
		debug(dt)

		debug(getage('1973-12-19'))

		debug(diffdate(dt, '2019-2-1'))
		debug(daysaway('Oct 19, 2019'))
	end

	def test_loadjson() 
		dic = loadjson('E:/myCoding/python/projects/utils/python_labs/env/Lib/site-packages/pycodestyle-2.5.0.dist-info/metadata.json')
		#debug('test', 'debug', dic)	
	end

	def test_files()
		fpath = 'E:/myCoding/python/projects/utils/python_labs/env/Lib/site-packages/pycodestyle-2.5.0.dist-info/metadata.json'
		fage = fileage(fpath)
		debug('file modified day(s) before', timeasday(fage))
	end

	def test_addtonil()
		puts nil + 3
	end

	def dividebyzero()
		30 / 0
	end

	def raise_error()
		begin
			test_addtonil()
		rescue => exception
			error_handler(exception)
		end
	end

	def test_cast()
		debug('is integer? ', is_integer?(3))
		debug('is integer? ', is_integer?('3'))
		debug('is integer? ', is_integer?('3.4'))
		debug('is float? ', is_float?(3.4))
		debug('is float? ', is_float?('3'))
		debug('is floate? ', is_float?('3.4'))
		debug('is email?', is_email?('test@1234'))
		debug('is email?', is_email?('test.com'))
		debug('try cast', trycast('3.5'))
		debug('try cast', trycast('3'))
		debug('try cast', trycast('A3'))
		debug('to be int', tobeint('345.4km'))
		debug('to be amount', tobeamount('1118.543'))
		debug('to be alphanum', tobealphanum('abc - 123,596#$%^^'))
		debug('to be nonspace', tobenonspace('1 2 3 a b c !@#$ $^&&*'))
	end

	def test_file()
		fpath = 'E:/work/Ingenuous/OneDrive - ingenuous.com.au/Projects/EWB/Documents from EWB/INSTINCT_FLAT_FILES_FROM_CAS_ASCCEND/AUTO_LOAN_FILE/ADDRESS_12202018.txt'
		files = Dir[File.dirname(fpath) + '/*.txt']
		LogUtil.debug('files of the folder: (%d)' % files.length,  files)
		LogUtil.debug('get key records of a file', getlinesofkey(fpath, '^2164003'))
		LogUtil.debug('get jsons of a file', getrecordsofkey(fpath, '^2164003'))
		LogUtil.debug('get file in the folder with pattern', getfileoffolder(File.dirname(fpath), '/CAS_APPLICATIONS*.txt'))
	end

	def test_parsebatch()
		ib = InstinctBatch.new(jsonpath: "E:/work/Ingenuous/OneDrive - ingenuous.com.au/poc/TH-Summit/prep/logstash/subwork/mapInstinct.json",countrycode: 'TH', org:'SUT')
		bline = ib.generatesample()
		FileUtil.writetofile(bline, './outputs/B_sample_summitth.txt')
		parsedrec = ib.parserecord(batchline: bline)
		FileUtil.writejson(parsedrec, './sampleparsed.json')
		return parsedrec
	end

	def test_csv()
		hashcsv = CSVUtil.csvtojson('E:/work/Ingenuous/OneDrive - ingenuous.com.au/poc/TH-Summit/prep/logstash/subwork/intuitionmap.csv', "\t")
		LogUtil.debug(hashcsv)
	end

	def test_genmapper()
		rnames = ['John', 'Paul', 'Andy', 'Bill', 'Jane', 'Jessie', 'Alita','Maria','Tony','Juliet']
		mapper = IntuitionMapper.new(csvpath: 'E:/work/Ingenuous/OneDrive - ingenuous.com.au/poc/TH-Summit/prep/logstash/subwork/intuitionmap.csv', delimiter: "\t")
		FileUtil.writejson(mapper.mapperJSON, './outputs/mapIntuition.json')
		srcrec = test_parsebatch()
		robot = Robot.new
		LogUtil.debug(robot)
		srcrec['Applicant'].each do |rec|
			rec['First Name'] = rnames.sample
			rec['Surname'] = rnames.sample
		end
		srcrec['U2A'][0]['User Field 31'] = srcrec['Applicant'][0]['First Name']
		srcrec['U2A'][0]['User Field 32'] = srcrec['Applicant'][0]['Surname']

		LogUtil.debug('U2A', srcrec['U2A'][0]['User Field 31'],srcrec['Applicant'][0]['First Name'])	
		mapper.mapsource(srcrec)
	end
end

#test_parsebatch()
	TestUtils.test_csv()
	TestUtils.test_genmapper()
	#puts(JSON.pretty_generate(dic))
	#TestUtils.test_parsedate
	#TestUtils.test_loadjson
	#TestUtils.test_files
	#TestUtils.raise_error
	#TestUtils.test_cast
	#TestUtils.test_file 
