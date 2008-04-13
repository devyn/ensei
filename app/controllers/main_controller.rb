class MainController < ApplicationController
	def index;end
	# sample Ensei windows
	def rssLoader
		require 'rss/2.0'
		@feed = RSS::Parser.parse(Net::HTTP.get(URI.parse(params['uri'])))
	end
	def clock; end
	def help; end
	def menu; end
	def terminal; end
end
