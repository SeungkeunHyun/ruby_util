class InstinctBatch
	def initialize(jsonpath:, countrycode:, org:)
		@jsondic = FileUtil.loadjson(jsonpath)
		@countrycode = countrycode
		@org = org
		generatemerges()
		#debug(@jsondic)
	end

	def generatemerges()
		@merges = [{'category' => 'Application', 'field_name' => 'AppKey', 'delimiter' => '', 'fields' => ['Organisation', 'Country Code', 'Application Number', 'Application Type']}]
		@merges << {'category' => 'Applicant', 'field_name' => 'Full_Name', 'delimiter' => ' ', 'fields' => ['First Name', 'Middle Name', 'Surname']}
		@merges << {'category' => 'Applicant', 'field_name' => 'Full_Home_Address', 'delimiter' => ' ', 'fields' => ["Home Address 1","Home Address 2","Home Address 3","Home Address 4","Home Address 5","Home Address 6","Home Postcode"]}
		@merges << {'category' => 'Applicant', 'field_name' => 'Full_Company_Address', 'delimiter' => ' ', 'fields' => ["Company Address 1","Company Address 2","Company Address 3","Company Address 4","Company Address 5","Company Address 6","Company Postcode"]}
		@merges << {'category' => 'Accountant/Solicitor', 'field_name' => 'Full_Name', 'delimiter' => ' ', 'fields' => ['First Name', 'Middle Name', 'Surname']}
		@merges << {'category' => 'Valuer', 'field_name' => 'Full_Address', 'delimiter' => ' ', 'fields' => ["Company Address 1","Company Address 2","Company Address 3","Company Address 4","Company Address 5","Company Address 6","Company Postcode"]}
		@merges << {'category' => 'Security', 'field_name' => 'Full_Address', 'delimiter' => ' ', 'fields' => ["Home Address 1","Home Address 2","Home Address 3","Home Address 4","Home Address 5","Home Address 6","Home Postcode"]}		
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
						LogUtil.debug('Date of birth', k, fn, fv)										
						ageofapp = DateUtil.getage(fv)
					end
				end
				frec['Age_of_Applicant'] = ageofapp
			end
		end
	end

	def generatesample(delimiter: '|')
		rec = []
		@jsondic.each do |c, fields|
			LogUtil.debug('category: ', c)
			unless fields[0].key?('category_identifier')
				rec << fields.map { |fld| 
					case fld['Field']
					when /Organisation/i
						@org
					when /Application number/i
						DateUtil.generatetimeinms()
					when /Application Type/i
						['AUTO', 'LOAN', 'CARD'].sample
					when /Country Code/i
						@countrycode
					else
						fld['Field'] 
					end
				}
				next
			end
			subcat = fields.map { |fld| 
				if fld.key?('category_identifier')
					fld['category_identifier']
				else
					if fld['Field'] =~ /Date of Birth/i
						DateUtil.generaterandomdob().strftime('%d/%m/%Y')
					elsif fld['Field'] =~ /Sex/i
						['M', 'F'].sample
					elsif fld['Type'] =~ /datetime/i
						DateUtil.generatedatelately().strftime('%d/%m/%Y')
					elsif fld['Type'] =~ /int/i
						DateUtil.generatetimeinms()
					else
						fld['Field'] 
					end
				end
			}
			rec << subcat
			if c == 'Applicant'
				2.times do 
					rec << subcat
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
		cat = nil
		@jsondic.each do |cat, f|
			if cat == 'Application'
				next
			end
			fdic = f.map(&:clone)
			fidx = fdic.shift()
			if cid == fidx['category_identifier']
				catdef = fdic
				(dic[cat] ||= []) << subdic
				LogUtil.debug('found category ', cat)
				break
			end
		end
		unless catdef
			error('invalid category', cid)
			return
		end
		catdef.each do |fdef|
			fname = fdef['Field']
			val = fields.shift()
			case fdef['Type']
			when /datetime/i
				unless DateUtil.parsedate(val)
					warn("#{cat}.#{fname} is invalid datetime", val)
					subdic[fname] = nil
					continue
				end
				subdic[fname] = val
			when /int/i
				subdic[fname] = RegxUtil.trycast(val)
			else
				subdic[fname] = val
			end
		end
		if fields.length > 1
			mapsubcategory(fields, dic)
		end
	end

	def mergefields(dic)
		fields = []
		@merges.each do |rec|
			if rec['category'] == 'Application'
				fields = rec['fields'].map { |fld| dic[fld] }.compact
				LogUtil.debug('fields to be concatenated', fields)							
				dic[rec['field_name']] = fields.join(rec['delimiter'])
				next
			end
			dic[rec['category']].each do |cat|
				fields = rec['fields'].map { |fld| cat[fld] }.compact
				LogUtil.debug('fields to be concatenated', fields)
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