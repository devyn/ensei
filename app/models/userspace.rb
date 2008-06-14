class Userspace < ActiveRecord::Base
	belongs_to :user
	def contents
		require 'z3'
		Z3.new(Base64.decode64(self['contents']))
	end
	def contents=(z3)
		self['contents'] = Base64.encode64(z3.save)
	end
end
