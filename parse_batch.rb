class InstinctBatch
	def initialize(jsonpath:)
		@jsondic = loadjson(jsonpath)
		generatemerges()
		#debug(@jsondic)
	end

	def generatemerges()
		@merges = [{'category' => 'Application', 'field_name' => 'AppKey', 'delimiter' => '', 'fields' => ['Organisation', 'Country Code', 'Application Number', 'Application Type']}, {'category' => 'Applicant', 'field_name' => 'Full_Name', 'delimiter' => ' ', 'fields' => ['First Name', 'Middle Name', 'Surname']}]
	end

	def calculatefield(dic) 
		#count of applicant
		dic['Number_of_Applicants'] = dic['Applicant'].length
		dic.each do |k,f|
			if f.class != Array
				next
			end	
			f.each do |frec|
				ageofapp = nil
				frec.each do |fn, fv|
					if fn =~ /Date of Birth/i
						debug('Date of birth', k, fn, fv)										
						ageofapp = getage(fv)
					end
				end
				frec['Age_of_Applicant'] = ageofapp
			end
		end
	end

	def generatesample(delimiter: '|')
		rec = []
		@jsondic.each do |c, fields|
			debug('category: ', c)
			unless fields[0].key?('category_identifier')
				rec += fields.map { |fld| fld['Field'] }
				next
			end
			subcat = fields.map { |fld| 
				if fld.key?('category_identifier')
					fld['category_identifier']
				else
					if fld['Field'] =~ /Date of Birth/i
						generaterandomdob().strftime('%d/%m/%Y')
					else
						fld['Field'] 
					end
				end
			}
			rec += subcat
			if c == 'Applicant'
				2.times do 
					rec += subcat
				end
			end
		end
		return rec.join(delimiter)
	end

	def mapsubcategory(fields, dic)
		if fields.length < 2
			return
		end
		cid = fields.shift()
		catdef = nil
		subdic = {}
		@jsondic.each do |cat, f|
			if cat == 'Application'
				next
			end
			fdic = f.map(&:clone)
			fidx = fdic.shift()
			if cid == fidx['category_identifier']
				catdef = fdic
				(dic[cat] ||= []) << subdic
				debug('found category ', cat)
				break
			end
		end
		unless catdef
			error('invalid category', cid)
			return
		end
		catdef.each do |fdef|
			fname = fdef['Field']
			subdic[fname] = fields.shift()
		end
		if fields.length > 1
			mapsubcategory(fields, dic)
		end
	end

	def mergefields(dic)
		fields = []
		@merges.each do |rec|
			if rec['category'] == 'Application'
				fields = rec['fields'].map { |fld| dic[fld] }
				debug(fields)
				dic[rec['field_name']] = fields.join(rec['delimiter'])
				next
			end
			dic[rec['category']].each do |cat|
				fields = rec['fields'].map { |fld| cat[fld] }
				cat[rec['field_name']] = fields.compact.join(rec['delimiter'])
			end
		end
	end

	def parserecord(batchline:, delimiter: '|')
		dic = {}
		batchline = batchline.strip
		fields = batchline.split(delimiter)
		@jsondic['Application'].each do |f|
			fname = f['Field']
			dic[fname] = fields.shift()
		end
		mapsubcategory(fields, dic)
		mergefields(dic)
		calculatefield(dic)
		return dic
	end
end