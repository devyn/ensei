require 'digest/sha2'
class DfsController < ApplicationController
	def client
		if params[:format] == 'json'
			require 'json'
			case params[:part]
				when 'login'
					token = rand(255*255*255*255).to_s(16)
					while UserTokens.keys.include? token
						token = rand(255*255*255*255).to_s(16)
					end
					if u = User.find(:all).select{|u|(u.name =~ /^#{params[:username]}$/i) and (u.pass == Base64.encode64(Digest::SHA256.digest(params[:password])))}.first
						UserTokens[token] = u.name
						render :text => token
					else
						render :text => "", :status => 403
					end
				when 'logout'
					UserTokens.delete(params[:token]) rescue nil
					render :text => ""
				when 'signup'
					if User.find(:all).select{|u|u.name =~ /^#{params[:username]}$/i} == []
						u = User.new
						u.name = params[:username]
						u.pass = Base64.encode64(Digest::SHA256.digest(params[:password]))
						u.data = {}
						u.save
						render :text => ""
					else
						render :text => "", :status => 500
					end
				when 'appList'
					render(:text => "", :status => 403) unless UserTokens[params[:token]]
					u = User.find(:first, :conditions => {:name => UserTokens[params[:token]]})
					render :text => JSON.dump(u.data.keys)
				when 'getSector'
					render(:text => "", :status => 403) unless UserTokens[params[:token]]
					u = User.find(:first, :conditions => {:name => UserTokens[params[:token]]})
					render :text => JSON.dump(u.data[params[:app]][params[:name]]) rescue render :text => "", :status => 404
				when 'dataList'
					render(:text => "", :status => 403) unless UserTokens[params[:token]]
					u = User.find(:first, :conditions => {:name => UserTokens[params[:token]]})
					render :text => JSON.dump(u.data[params[:app]].keys) rescue render :text => "", :status => 500
				when 'sendSector'
					render(:text => "", :status => 403) unless UserTokens[params[:token]]
					u = User.find(:first, :conditions => {:name => UserTokens[params[:token]]})
					x = u.data.dup
					x[params[:app]] = {} unless x[params[:app]]
					if params[:value] == 'null'
						x[params[:app]].delete(params[:name])
					else
						x[params[:app]][params[:name]] = JSON.load(params[:value])
					end
					u.data = x
					u.save
					render :text => ""
				else
					render(:text => "", :status => 404)
			end
			elsif params[:format] == "rbo"
				case params[:part]
					when 'login'
						token = rand(255*255*255*255).to_s(16)
						while UserTokens.keys.include? token
							token = rand(255*255*255*255).to_s(16)
						end
						if u = User.find(:all).select{|u|(u.name =~ /^#{params[:username]}$/i) and (u.pass == Digest::SHA256.digest(params[:password]))}.first
							UserTokens[token] = u.name
							render :text => Marshal.dump(token)
						else
							render :text => Marshal.dump(nil), :status => 403
						end
					when 'logout'
						UserTokens.delete(params[:token]) rescue nil
						render :text => Marshal.dump(true)
					when 'signup'
						if User.find(:all).select{|u|u.name =~ /^#{params[:username]}$/i} == []
							u = User.new
							u.name = params[:username]
							u.pass = Digest::SHA256.digest(params[:password])
							u.data = {}
							u.save
							render :text => Marshal.dump(true)
						else
							render :text => Marshal.dump(nil), :status => 500
						end
					when 'appList'
						render(:text => Marshal.dump(nil), :status => 403) unless UserTokens[params[:token]]
						u = User.find(:first, :conditions => {:name => UserTokens[params[:token]]})
						render :text => Marshal.dump(u.data.keys)
					when 'getSector'
						render(:text => Marshal.dump(nil), :status => 403) unless UserTokens[params[:token]]
						u = User.find(:first, :conditions => {:name => UserTokens[params[:token]]})
						render :text => Marshal.dump(u.data[params[:app]][params[:name]]) rescue render :text => Marshal.dump(nil), :status => 404
					when 'sendSector'
						render(:text => Marshal.dump(nil), :status => 403) unless UserTokens[params[:token]]
						u = User.find(:first, :conditions => {:name => UserTokens[params[:token]]})
						x = u.data.dup
						x[params[:app]] = {} unless x[params[:app]]
						x[params[:app]][params[:name]] = Marshal.load(params[:value])
						x[params[:app]].reject!{|k,i| not i}
						u.data = x
						u.save
						render :text => Marshal.dump(true)
					when 'dataList'
						render(:text => Marshal.dump(nil), :status => 403) unless UserTokens[params[:token]]
						u = User.find(:first, :conditions => {:name => UserTokens[params[:token]]})
						render :text => Marshal.dump(u.data[params[:app]].keys) rescue render :text => Marshal.dump(nil), :status => 500
					else
						render :text => Marshal.dump(nil), :status => 404
				end
		end
	end
	def manager;end
end
