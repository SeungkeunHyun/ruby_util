module CSVUtil
# Currently loads csv file and make it to hash of each row
	module_function

	# .csv file shoudl have a column header at the first line	
	#
	# @param [String] path file path of a csv to read
	#
	# @param [String] delimiter column delimiter in a csv
	#
	# @return [Array] hashed csv rows

	def csvtojson(path, delimiter)
		data = CSV.open(path, 'r', :col_sep => delimiter, :headers => true)
		return data.map { |row| row.to_hash }
	end

end