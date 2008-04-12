# Ensei Service Skin Rendering
require 'rexml/document'
require 'cgi'

module Ensei; end unless defined?(Ensei) # declare Ensei
class Ensei::EnseiError < Exception; end unless defined?(Ensei::EnseiError)

module Ensei::Skin
	def self.render(skin, data)
		skin = REXML::Document.new(skin).root
		return false unless skin.name =~ /^enseiServiceSkin$/i
		html = ""
		skin.elements.each do |e|
			html << "<span style='"
			e.attributes.each do |k,v|
				html << "#{k}:#{v};"
			end
			html << "'>#{CGI.escapeHTML(data[e.name] or "")}</span>"
		end
		return html
	end
end