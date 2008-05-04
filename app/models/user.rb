class User < ActiveRecord::Base
	def data
		Marshal.load(Base64.decode64(self['data']))
	end
	def data=(p)
		self['data'] = Base64.encode64(Marshal.dump(p))
	end
end
