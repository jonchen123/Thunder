require 'sinatra'
require 'twilio-ruby'
require 'google_places'
#require 'google_maps'

post '/sms' do
	#create new variable that stores the body of the message sent
	incoming = params[:Body]

	#mapclient = GoogleMaps::Client.new('AIzaSyCkLbMGDVjRdFjb9EHm4e9HJdm6XzVPzYk')
	
	#create new client to Google Places with my API key
	client = GooglePlaces::Client.new('AIzaSyCkLbMGDVjRdFjb9EHm4e9HJdm6XzVPzYk')
	#Google will do the work for you and find the best place for you, which corresponds to
	#the 0th element in the array
	#the types will give you places that match the category you want
	#the radius will restrict the distance of places around you
	best_place = client.spots_by_query(incoming, :types => ['food'], :radius => 16000)[0]
	#route = mapclient.

	#this will create a new twilio response
	twiml = Twilio::TwiML::Response.new do |r|
		r.Message("Found #{best_place.name}. The address is #{best_place.formatted_address}")
	end

	#for easier http communication
	content_type 'text/xml'
	#send a text back from your twilio account
	twiml.text
end

#maybe add functionality to return a map of the route to the place from you
# @formatted_address is the address of place returned by google
# or use @lat and @lng