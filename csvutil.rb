module CSVUtil
	module_function

	def csvtojson(path, delimiter)
		data = CSV.open(path, 'r', :col_sep => delimiter, :headers => true)
		return data.map { |row| row.to_hash }
	end

end