require 'sinatra'
require 'datamapper'
require 'uri'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/pubs.db")

class Pub
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :address, String
	property :lat, Decimal
	property :long, Decimal
end

DataMapper.finalize.auto_upgrade!
helpers do
	include Rack::Utils
	alias_method :h, :escape_html
	

	def hash_to_query(hash)
		hash.map do |key, value|
			if value.is_a?(Array)
				#convert {:key => [value1. value2, value3]}
				#[[:key, value1], [:key, value2], [:key, value3]]
			   new_hash = value.map{|v| [key, v]}
			   hash_to_query(new_hash)
			else
				"#{key}=#{URI.escape(value)}"
			end
		end.join("&")
	end
	def google_maps_url(params = {})
		params[:sensor] = "false"
		params[:maptype] = "roadmap"
		params[:size] = "1024x1024"
		params[:center] = "2007 Walnut Street,Philadelphia,PA"
		"http://maps.google.com/maps/api/staticmap?" + hash_to_query(params)
	end
end	

get '/' do
	@pubs = Pub.all
	@pub_markers = @pubs.map {|pub| "label:#{pub.id}|#{pub.address}" }
	erb :home
end

post '/' do
	Pub.create(params)
	redirect '/'
end
