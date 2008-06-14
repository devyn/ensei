class FilesController < ApplicationController
	def index
		@path = params[:path] or '/'
		render :status => 403, :text => '' unless UserTokens[params[:token]]
		@user = User.find(:first, :conditions => {:name => UserTokens[params[:token]]})
		@z3 = @user.userspace.contents
		@things = @z3.things_in(@path)
		case params[:format]
			when /^html?$/i
			when ''
			when /^json$/i
				require 'json'
				render :text => JSON.dump(@things)
			when /^ya?ml$/i
				require 'yaml'
				render :text => YAML.dump(@things)
			when /^rbo$/i
				render :text => Marshal.dump(@things)
			else
				raise ArgumentError, "invalid format"
		end
	end
end
