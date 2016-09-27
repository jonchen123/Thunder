require 'sinatra'
require 'twilio-ruby'
require 'google_places'
require 'google_map_directions'
require 'geocoder'

post '/sms' do
	#create new variable that stores the body of the message sent
	incoming = params[:Body]
	#find user location -- get this to work???
	#location = Geocoder.address(request.remote_ip)
	
	#create new client to Google Places with my API key
	client = GooglePlaces::Client.new('AIzaSyCkLbMGDVjRdFjb9EHm4e9HJdm6XzVPzYk')
	#Google will do the work for you and find the best place for you, which corresponds to
	#the 0th element in the array
	#the types will give you places that match the category you want
	#the radius will restrict the distance of places around you
	best_place = client.spots_by_query(incoming, :types => ['food'], :radius => 16000)[0]
	#get directions to best_place from user location
	directions = GoogleMapDirections::Directions.new("Atlanta GA", "#{best_place.formatted_address}")
	numSteps = directions.path_length

	#this will create a new twilio response
	twiml = Twilio::TwiML::Response.new do |r|
		#if nothing was found
		if best_place.nil?
			r.Message("Sorry, nothing was found. Try again.")
		else
			r.Message("Found #{best_place.name}. The address is #{best_place.formatted_address}")
			#send a message of each direction
			(0..numSteps - 1).each do |i|
				step = directions.step(i)
				r.Message(step.HTML_instructions)
			end
		end
	end

	#for easier http communication
	content_type 'text/xml'
	#send a text back from your twilio account
	twiml.text
end

#format the directions better
