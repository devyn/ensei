# Ensei Remote Services
require 'rexml/document'
require 'open-uri'
require 'cgi'
require 'json'
require 'skin'

module Ensei; end unless defined?(Ensei) # declare Ensei
class Ensei::EnseiError < Exception; end unless defined?(Ensei::EnseiError)

# this is for Ensei service files
class Ensei::Service
	def initialize(service_uri)
		@uri = URI.parse(service_uri.class == URI ? service_uri.to_s : service_uri).to_s
	end
	def get_format
		root = REXML::Document.new(open(@uri).read).root rescue return false
		return false unless root.name =~ /^enseiServiceFormat$/i
		root.elements.collect{|x|x.name}
	end
	def retrieve(params)
		params.class >= Hash ? nil : raise 'parameters must be hash'
		uri = URI.parse(@uri)
		uri.query = make_query(params)
		root = REXML::Document.new(open(uri.to_s).read).root rescue return false
		return false unless root.name =~ /^enseiService$/i
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
	def html(params=nil, formRequestURL=nil, winID=nil)
		if params
			retrieved_data = retrieve params
			return Ensei::Skin.render(open(retrieved_data['skin']).read, retrieved_data)
		elsif formRequestURL and winID
			fields = get_format
			cNum = winID
			script = "function x#{cNum}_update() { Element.update('#{cNum}', new Ajax.Request('#{formRequestURL}', {method:'post', postBody:{"
			str = "<form>"
			fields.each_with_index do |fi, ind|
				script << "#{fi}: document.evaluate('//input[id='#{cNum}_#{fi}']', document, null, XPathResult.ANY_TYPE, null).iterateNext().value#{"," unless ind == (fields.size - 1)} "
				str << "#{CGI.escapeHTML(fi)}: <input id='#{cNum}_#{fi}'/><br/>"
			end
			script << "}}).responseText); }"
			form << "<a href='javascript:x#{cNum}_update()'>load window</a></form>"
			return "<script>#{script}</script>#{form}"
		else
			raise ArgumentError, "Must provide parameters or formRequestURL."
		end
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