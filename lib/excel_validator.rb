require 'active_model'
require 'active_model/validations'
require 'roo'

class ExcelValidator < ActiveModel::EachValidator
	@@default_options = {}

	def self.default_options
		@@default_options
		puts @@default_options
	end

	def validate_each(record, attribute, value)
		options = @@default_options.merge(self.options)

		unless value
			record.errors.add(attribute, options[:message] || "must be present")
			return
		end

		begin
			excel = ::Roo::Spreadsheet.open(value.path)
		rescue Exception => e
			record.errors.add(attribute, options[:message] || "is not a valid CSV file")
			return
		end

		if options[:columns]
			header_starts= options[:header_starts_from] || 1
			unless excel.row(header_starts).length == options[:columns]
				record.errors.add(attribute, options[:message] || "should have #{options[:columns]} columns")
			end
		end
		
		if options[:header_values]
			header_starts= options[:header_starts_from] || 1
			unless  options[:header_values].map(&:downcase).sort == excel.row(header_starts).map(&:downcase).sort
			 	record.errors.add(attribute, options[:message] || "not valid headers")
			end
		end

		if options[:email]
			header_starts= options[:header_starts_from] || 1
			emails = column_to_array(excel, options[:email],header_starts)
			invalid_emails = []
			emails.each do |email|
				begin
					valid = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i === email
				rescue
					valid = false
				end
				unless valid
					invalid_emails << email
				end
			end

			if invalid_emails.length > 0
				record.errors.add(attribute, options[:message] || "contains invalid emails (#{invalid_emails.join(', ')})")
			end
		end

		if options[:numericality]
			numbers = column_to_array(excel, options[:numericality])
			numbers.each do |number|
				unless is_numeric?(number)
					record.errors.add(attribute, options[:message] || "contains non-numeric content in column #{options[:numericality]}")
					return
				end
			end
		end

	end

	private

	def column_to_array(excel, column_index,header_starts=1)
		excel.column(column_index).drop(header_starts).map {|column| column.blank? ? "" : column.downcase.squish}
	end

	def is_numeric?(string)
		Float(string)
		true
	rescue
		false
	end


end
