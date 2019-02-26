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
#puts(JSON.pretty_generate(dic))
test_parsedate
test_loadjson
test_files