# Ensei Remote Services
require 'rexml/document'
require 'open-uri'
require 'cgi'
require 'json'

module Ensei; end unless defined?(Ensei) # declare Ensei
class Ensei::EnseiError < Exception; end

# this is for Ensei service files
class Ensei::Service
	def initialize(service_uri)
		@uri = URI.parse(service_uri.class == URI ? service_uri.to_s : service_uri)
	end
	def get_format
		root = REXML::Document.new(open(@uri).read).root rescue return false
		root.elements.collect{|x|x.name}
	end
	def retrieve(params)
		params.class >= Hash ? nil : raise 'parameters must be hash'
		uri = @uri.dup
		uri.query = make_query(params)
		root = REXML::Document.new(open(uri).read).root rescue return false
		if (o = root.attributes.select{|x, v| x =~ /^enseiError$/i}).size > 0
			raise EnseiError, root.attributes[o[0]]
		end
		h = {}
		root.attributes.each do |k, v|
			h[k] = v
		end
		root.elements.each do |e|
			h[e.name] = e.text
		end
		h
	end
	def to_proto_js(winId, backTo, timeout, params={})
		return(<<-EOF)
			function update_#{winId}() {
				var resp = new Ajax.Request('#{backTo}', {parameters:#{params.to_json}});
				eval(resp.responseText);
			}
			setTimeout(update_#{winId}, #{timeout.to_i});
		EOF
	end
	private; def make_query(h)
		str = ""
		h.each_with_index do |x,i|
			key, value = x
			str << CGI.escape(key.to_s) << "=" << CGI.escape(value.to_s)
			str << "&" unless i == (h.size - 1)
		end
		str
	end
end