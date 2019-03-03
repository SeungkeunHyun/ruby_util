class IntuitionMapper
	def initialize(csvpath:, delimiter: "\t")
		@csvpath = csvpath
		@delimiter = delimiter
		generateMapperJSON()
		LogUtil.debug(@mapperJSON)
	end

	def generateMapperJSON()
		@mapperJSON = {}
		subdic = nil
		CSV.read(@csvpath, {:col_sep => @delimiter, :headers => true}).each do |row|
			fname = row['Field_Name']
			if row['Type']
				if subdic
					subdic[fname] = row.to_hash
				else
					@mapperJSON[fname] = row.to_hash
				end
			else
				subdic = {}
				(@mapperJSON[fname] ||= []) << subdic
			end
		end
	end

	def mapsource(srcrec)
		maprec = {}
		@mapperJSON.each do | c, f |
			if f.class == Array
				maprec[c] = mapsubrec(srcrec, f)
				next
			end
			fname, cat, fld = getkeys(f)
			unless cat && fld
				next
			end
			LogUtil.debug('category and field: ', cat, fld)
			if srcrec.key?(fld) && srcrec[fld]
				maprec[fname] = srcrec[fld]
				LogUtil.debug('found app field', fld, srcrec[fld])
			end
		end
		FileUtil.writejson(maprec, "./mapped/#{maprec['Request_Key']}.json")
		return maprec
	end

	def extractcats(colfld)
		cats = []
		colfld.each do |fname, fdef|
			if fdef['Instinct Category']
				cats = cats | [fdef['Instinct Category']]
			end
		end
		return cats
	end

	def casttype(val, typ)
		unless val
			return nil
		end
		case typ
		when /Text/i
			val = val.to_s
		when /Numeric/i
			val = RegxUtil.trycast(val)
		when /Date/i
			val = DateUtil.parsedate(val)
			unless val
				return nil
			end
			return val.strftime('%d/%m/%Y')
		else
			val
		end
		LogUtil.debug('try to cast', val, typ)
		return val
	end

	def mapsubrec(srcrec, fields)
		recs = []
		fields.each do |unitrec|
			cats = extractcats(unitrec)
			numrecs = cats.map {|e| srcrec[e] ? srcrec[e].length : 0 }.sum
			while numrecs > 0
				rec = {}
				src = nil
				cats.each do |cat|
					if cat == 'U2A' && srcrec.key?(cat) && srcrec[cat].length > 0
						LogUtil.debug('U2A check', srcrec[cat][0])
						srcrec[cat].each do |src|
							if rec['Name'] == src['User Field 31'] && rec['Surname'] == src['User Field 32']
								LogUtil.debug('found u2a for this applicant')
								mapsrctotarget(cat, src, rec, unitrec)		
								break
							end
						end
						srcrec[cat].delete(src)
						next 
					end
					if srcrec.key?(cat) && srcrec[cat].length > 0
						src = srcrec[cat].shift
						mapsrctotarget(cat, src, rec, unitrec)
					end
				end
				recs << rec
				numrecs = cats.map {|e| srcrec[e] ? srcrec[e].length : 0 }.sum
				cats = cats.map {|e| 
					if srcrec[e] && srcrec[e].length == 0
						nil
					else
						e
					end
				}.compact
				if cats == ['U2A']
					break
				end
			end
			LogUtil.debug(cats, recs)
		end
		return recs
	end

	def mapsrctotarget(cat, src, rec, unitrec)
		unitrec.each do |k, f|
			if f['Instinct Category'] != cat
				if f['Comments'] =~ /Hardcode to (\S+)/
					rec[k] = $1
				end
				next
			end
			fname = f['Instinct Field']
			if src.key?(fname) && src[fname] != ''
				val = casttype(src[fname], f['Type'])
				if val 
					rec[k] = val
				end
			end
		end
	end

	def getkeys(field)
		LogUtil.debug(field)
		return [field['Field_Name'], field['Instinct Category'], field['Instinct Field']]
	end
end
