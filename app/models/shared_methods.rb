module SharedMethods 
	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods
		def active_list
			where(is_deleted: FALSE)
		end
	end

	module Parser
		def self.Boolean(string)
			string = string.to_s
			return true if string==true || string =~ (/(true|t|yes|y|1)$/i)
			return false if string==false || string.nil? || string =~ (/(false|f|no|n|0)$/i)
			raise ArgumentError.new("invalid value for Boolean: #{string}")
		end
	end
end
