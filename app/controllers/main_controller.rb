class MainController < ApplicationController
	after_filter :choose_content_type
	def index;end
	# sample Ensei windows
	def rssLoader
		require 'rss/2.0'
		@feed = RSS::Parser.parse(Net::HTTP.get(URI.parse(params['uri'])))
	end
	def clock; end
	def help; end
	def menu; end
	def terminal
		if params[:format] == "js"
			# right now pretty pointless.
			require 'resh'
			exe = Resh::Executor.new
			%w[openService newWindow refreshWindow setContent getContent closeWindow setTitle getIFrameDocument moveWindow fetchWins setShade persistentWindowsSave persistentWindowsLoad processLogin processSignup logout focusWindow unFocusWindow reshTransport].each do |i|
				exe.des.define(i) {|pipedata,arguments|
					i << "(" << process_args(arguments).collect{|i|'"' << i.gsub('"', '\"') << '"'}.join(", ") << ");"
				}
			end
			obj = exe.execute(params[:script])
			headers['X-JSON'] = obj.to_json
			render :text => obj.join("\n")
		end
	end
	
private
	def choose_content_type
		headers['Content-Type'] = Mime::JS if params[:format] == "js"
	end
end
