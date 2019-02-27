require './util.rb'

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
	dic = loadjson('E:\myCoding\python\projects\utils\python_labs\env\Lib\site-packages\pycodestyle-2.5.0.dist-info\metadata.json')
	#debug('test', 'debug', dic)	
end

def test_files()
	fpath = 'E:\myCoding\python\projects\utils\python_labs\env\Lib\site-packages\pycodestyle-2.5.0.dist-info\metadata.json'
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
	debug('try cast', trycast('3.5'))
	debug('try cast', trycast('3'))
	debug('try cast', trycast('A3'))
	debug('to be int', tobeint('345.4km'))
	debug('to be amount', tobeamount('1118.543'))
	debug('to be alphanum', tobealphanum('abc - 123,596#$%^^'))
	debug('to be nonspace', tobenonspace('1 2 3 a b c !@#$ $^&&*'))
end
#puts(JSON.pretty_generate(dic))
test_parsedate
test_loadjson
test_files
raise_error
test_cast