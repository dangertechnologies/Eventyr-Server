# Crawls Google and FourSquare for interesting locations and creates
# achievements and objectives from these.
#
# This requires providing the name of a city - or a country, in which case
# all cities will first be identified using another API to retrieve coordinates,
# then each city will be crawled.
#
require 'open-uri'
require 'json'
require 'wikipedia'
require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'

namespace :crawl do


  task :foursquare, [:search] => :environment do |task, args|
    results = scrape_foursquare(args.search)


    puts '==========================================================='
    puts "Created: %d" % [results[:total_created]]
    puts "Updated: %d" % [results[:total_updated]]
    puts "Total: %d" % [results[:total_created] + results[:total_updated]]
  end
end

def scrape_google(search)
  objective_prefixes = ["Visit %s",
                "Go to %s",
                "Check out %s",
                "Arrive at %s",
                "See %s",
                "Pay a visit to %s",
                "Show up at %s",
                "Stop at %s",
                "Get to %s",
                "Travel to %s",
                "Reach %s"]

  achievement_prefixes = ["A visit to %s",
                "A journey towards %s",
                "Checking out %s",
                "A stop by %s",
                "Falling by %s",
                "A trip to %s",
                "Seeing %s",
                "Arriving at %s",
                "What\"s %s?",
                "Getting to %s",
                "Approaching %s",
                "Reaching %s"
  ]

  # API key to use
  api_key = ENV['GOOGLE_KEY']

  # Types of places we want to crawl for:
  place_types = [
      'mosque',
      'church',
      'stadium',
      'synagogue',
      'train_station',
      'university',
      'hindu_temple',
      'subway_station',
      'city_hall',
  ]

  # URL to use
  api_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?radius=50000&types=natural_feature&key=#{api_key}&location="

  # Get the coordinates
  geocoded_search = Geokit::Geocoders::GoogleGeocoder.geocode(search)

  location = Location.new(x: geocoded_search.lat, y: geocoded_search.lng, z: 0)

  # Perform the request
  request = JSON.parse(open(api_url+"%s,%s" % [location.x.to_s, location.y.to_s]).read)


  # Count amount of created and updated achievements
  total_updated = 0
  total_created = 0

  # Parse the returned data
  if request["status"] == "OK"
    request["results"].each do |place|

      # Dont get establishments and businesses
      #unless place["types"].include? "establishment"
      unless place["types"].nil?
        place_location = Location.where(x: place["geometry"]["location"]["lat"],
                                        y: place["geometry"]["location"]["lng"],
                                        z: 0).first_or_create

        # Find or create the country
        reverse_geocoded_location = Geokit::Geocoders::GoogleGeocoder.reverse_geocode(place_location)

        place_location.country = Country.where(name: reverse_geocoded_location.country).first_or_create

        # Create an objective

        if place.has_key? "rating"
          o_base_points = place["rating"].to_i*10
        else
          o_base_points = Random.rand(50) + 5
        end

        if Objective.exists? hash_identifier: Digest::MD5.hexdigest(place["name"])
          o = Objective.find_by(hash_identifier: Digest::MD5.hexdigest(place["name"]))
          total_updated += 1
        else
          o = Objective.create(hash_identifier: Digest::MD5.hexdigest(place["name"]),
                               base_points: o_base_points,
                               required_count: 1,
                               goal: place_location,
                               tagline: objective_prefixes[Random.rand(objective_prefixes.count)] % place["name"]
          )

          total_created += 1
        end


        unless o.valid?
          puts o.errors.messages
        end



        # Find or create a category
        if place["types"].count > 1
          place["types"].delete "point_of_interest"
        end


        c = Category.where(title: place["types"].first.gsub(/_/, ' ').capitalize).first_or_create

        # Set type to Location
        t = Type.where(name: 'Location').first_or_create

        # Set mode to Normal
        m = Mode.where(name: 'Normal').first_or_create

        # Create an Achievement and generate the base points as the distance
        # from the original location plus a random number between 5 and 25
        base_points = (place_location.distance_from(location, units: :meters) % 100) + (Random.rand(20)+5)

        a = Achievement.where(hash_identifier: Digest::MD5.hexdigest(place["name"])).first_or_create

        achievement_name = achievement_prefixes[Random.rand(achievement_prefixes.length)] % place["name"]

        wikipedia_page = Wikipedia.find(place['name'])

        unless wikipedia_page.text.nil? or wikipedia_page.text.include? 'may refer to'
          description = wikipedia_page.text

          description = description.split("== References").first if description.include? "== References"

          description = description.split("== See also").first if description.include? "== See also"

          description = description.split("== External").first if description.include? "== External"

          short_description = description

          short_description = short_description.split('\n') if short_description.include? '\n'
        else
          short_description = 'Automatically created achievement'
          full_description = 'Automatically created achievement'
        end

        a.update_attributes(name: achievement_name,
                            short_description: short_description.truncate(80),
                            full_description: description,
                            is_multiplayer: true,
                            is_global: true,
                            base_points: base_points,
                            kind: t,
                            category: c,
                            mode: m,
                            has_parents: false,
                            icon: Icon.find(52)
        )
        a.objectives << o unless a.objectives.include? o

        if a.valid?
          puts "| Name: #{a.name}"
          puts "| Short: #{a.short_description}"
          puts "| Desc: #{a.full_description}"
          puts "| Points: #{a.base_points}"
          puts "| -------"
          puts "| Creating Location for " << place["name"] << "..."
          puts "| Setting up objective '#{o.tagline}'"
          a.save
          puts "| Achievement #{a.name} saved with #{a.base_points} points and #{a.objectives.count} objectives"

        else
          puts "Achievement could not be created: "
          puts a.errors.messages
        end
      else
        puts "%s was an establishment, skipping because types were: %s " % [place["name"], place["types"].join(",")]
      end
    end
  end

  return {total_updated: total_updated, total_created: total_created}
end

def scrape_foursquare(search)
  categories = {
    "Beach"=>"4bf58dd8d48988d1e2941735", 
    "Botanical garden"=>"52e81612bcbc57f1066b7a22",
    "Bridge"=>"4bf58dd8d48988d1df941735",
    "Canal"=>"56aa371be4b08b9a8d573562",
    "Castle"=>"50aaa49e4b90af0d42d5de11",
    "Cave"=>"56aa371be4b08b9a8d573511",
    "Fishing spot"=>"52e81612bcbc57f1066b7a0f",
    "Forest"=>"52e81612bcbc57f1066b7a23",
    "Fountain"=>"56aa371be4b08b9a8d573547",
    "Hot spring"=>"4bf58dd8d48988d160941735",
    "Island"=>"50aaa4314b90af0d42d5de10",
    "Mountain"=>"4eb1d4d54b900d56c88a45fc",
    "National Park"=>"52e81612bcbc57f1066b7a21",
    "Nature preserve"=>"52e81612bcbc57f1066b7a13",
    "Park"=>"4bf58dd8d48988d163941735",
    "Rafting"=>"52e81612bcbc57f1066b7a29",
    "River"=>"4eb1d4dd4b900d56c88a45fd",
    "Scenic lookout"=>"4bf58dd8d48988d165941735",
    "Sculpture garden"=>"4bf58dd8d48988d166941735",
    "Skydiving drop zone"=>"58daa1558bbb0b01f18ec1b9",
    "State / Provincial park"=>"5bae9231bedf3950379f89d0",
    "Vinyard"=>"4bf58dd8d48988d1de941735",
    "Volcano"=>"5032848691d4c4b30a586d61",
    "Waterfall"=>"56aa371be4b08b9a8d573560",
    "Well"=>"4fbc1be21983fc883593e321",
    "Windmill"=>"5bae9231bedf3950379f89c7",
    "Observatory"=>"5744ccdfe4b0c0459246b4d9",
    
    "Spiritual center"=>"4bf58dd8d48988d131941735",
    "Buddhist temple" => "52e81612bcbc57f1066b7a3e",
    "Cemevi" => "58daa1558bbb0b01f18ec1eb",
    "Church" => "4bf58dd8d48988d132941735",
    "Confusian temple" => "56aa371be4b08b9a8d5734fc",
    "Hindu temple" => "52e81612bcbc57f1066b7a3f",
    "Kingdom hall" => "5744ccdfe4b0c0459246b4ac",
    "Monastery" => "52e81612bcbc57f1066b7a40",
    "Mosque" => "4bf58dd8d48988d138941735",
    "Prayer room" => "52e81612bcbc57f1066b7a41",
    "Shrine" => "4eb1d80a4b900d56c88a45ff",
    "Sikh temple" => "5bae9231bedf3950379f89c9",
    "Synagogue" => "4bf58dd8d48988d139941735",
    "Temple" => "4bf58dd8d48988d13a941735",
    "Terreiro" => "56aa371be4b08b9a8d5734f6",

    "Event"=>"4d4b7105d754a06373d81259",
    "Public art"=>"507c8c4091d498d9fc8c67a9",
    "Museum"=> "4bf58dd8d48988d181941735",
    "Science museum" => "4bf58dd8d48988d191941735",
    "Planetarium" => "4bf58dd8d48988d192941735",
    "History museum" => "4bf58dd8d48988d190941735",
    "Erotic museum" => "559acbe0498e472f1a53fa23",
    "Art museum" => "4bf58dd8d48988d18f941735",

    "Memorial sites"=>"5642206c498e4bfca532186c",
    "Amphitheatre"=>"56aa371be4b08b9a8d5734db",
    "Aquarium"=>"4fceea171983d5d06c3e9823",
    "Art gallery"=>"4bf58dd8d48988d1e2931735"
  }

  category_map = {
    "Nature & Wildlife": [
      "Beach",
      "Cave",
      "Fishing spot",
      "Forest",
      "Hot spring",
      "Island",
      "Mountain",
      "National Park",
      "Nature preserve",
      "Park",
      "River",
      "Scenic lookout",
      "Volcano",
      "Waterfall",
    ].map{ |c| categories[c] },
    "Culture": [
      "Botanical garden",
      "Castle",
      "Canal",
      "Bridge",
      "Fountain",
      "Vinyard",
      "Event",
      "Public art",
      "Museum",
      "History museum",
      "Art museum",
      "Science museum",
      "Planetarium",
      "Erotic museum",
      "Amphitheatre",
      "Art gallery",
      "Memorial sites",
      "Aquarium",
      "Sculpture garden",
      "State / Provincial park",
      "Windmill",

      "Spiritual center",
      "Buddhist temple" ,
      "Cemevi" ,
      "Church" ,
      "Confusian temple" ,
      "Hindu temple" ,
      "Kingdom hall" ,
      "Monastery" ,
      "Mosque" ,
      "Prayer room" ,
      "Shrine" ,
      "Sikh temple" ,
      "Synagogue" ,
      "Temple" ,
      "Terreiro" ,
    ].map{ |c| categories[c] },

    "Sports & Outdoors": [
      "Skydiving drop zone",
      "Rafting"
    ].map{ |c| categories[c] }
  }
  objective_prefixes = ["Visit %s",
                "Go to %s",
                "Check out %s",
                "Arrive at %s",
                "See %s",
                "Pay a visit to %s",
                "Show up at %s",
                "Stop at %s",
                "Get to %s",
                "Travel to %s",
                "Reach %s"]

  achievement_prefixes = ["A visit to %s",
                "A journey towards %s",
                "Checking out %s",
                "A stop by %s",
                "Falling by %s",
                "A trip to %s",
                "Seeing %s",
                "Arriving at %s",
                "What\"s %s?",
                "Getting to %s",
                "Approaching %s",
                "Reaching %s"
  ]

  # API key to use
  client_id = ENV['FOURSQUARE_CLIENT_ID']
  client_secret = ENV["FOURSQUARE_CLIENT_SECRET"]
  offset = 0


  # Get the coordinates
  geocoded_search = Geokit::Geocoders::MapboxGeocoder.geocode(search)

  auth_params = {
    client_id: client_id,
    client_secret: client_secret,
    v: "20180323",
  }
  params = {
    categoryId: categories.values.join(","),
    ll: [geocoded_search.lat, geocoded_search.lng].join(","), 
    intent: :browse,
    radius: 100_000,
    limit: 50,
  }.merge(auth_params)


  total_updated = 0
  total_created = 0

  
  api_url = "https://api.foursquare.com/v2/venues/search?#{params.merge(offset: offset.to_s).to_query}"

  puts api_url
  req = open(api_url).read

  # Perform the request
  request = JSON.parse(req)

  return unless request['meta']['code'].to_i == 200

  request['response']['venues'].each do |place|


    
    place_location = [place["location"]["lat"], place["location"]["lng"]]

    # Find or create the country
    #reverse_geocoded_location = Geokit::Geocoders::GoogleGeocoder.reverse_geocode(place_location)

    country = Country.where(name: "Norway").first_or_create

    
    details = JSON.parse(open("https://api.foursquare.com/v2/venues/#{place["id"]}?#{auth_params.to_query}").read)

    details = details["response"]["venue"]

    # Create an objective
    if details.has_key? 'rating'
      o_base_points = details['rating'].to_i * 5
    else
      o_base_points = Random.rand(50) + 5
    end

    if Objective.exists? hash_identifier: Digest::MD5.hexdigest(details['name'])
      o = Objective.find_by(hash_identifier: Digest::MD5.hexdigest(details['name']))
      total_updated += 1
    else
      o = Objective.create(hash_identifier: Digest::MD5.hexdigest(details['name']),
                            base_points: o_base_points,
                            required_count: 1,
                            lat: place_location[0],
                            lng: place_location[1],
                            country: country,
                            kind: :LOCATION,
                            tagline: objective_prefixes[Random.rand(objective_prefixes.count)] % details['name']
      )

      total_created += 1
    end


    unless o.valid?
      puts o.errors.messages
    end


    # Map category
    categories = category_map.find do |(key, value)| 
      place["categories"].map{ |c| c["id"] }.any? { |c| value.include?(c) } 
    end

    if !categories || categories.empty? 
      puts "No category for: "
      puts place["categories"].map{|c| c["id"]}
      puts place["categories"]

      category = Category.first
    else
      category = Category.find_by(title: categories.first)
    end

    

    # Set type to Location
    type = :LOCATION

    # Set mode to Normal
    mode = :NORMAL

    # Create an Achievement and generate the base points as the distance
    # from the original location plus a random number between 5 and 25
    distance = Geokit::GeoLoc.new(lat: place["lat"], lng: place["lng"]).distance_from(geocoded_search)
    base_points = (distance % 100) + (Random.rand(20)+5)

    a = Achievement.where(
      hash_identifier: Digest::MD5.hexdigest(details['name']),
    ).first_or_create

    achievement_name = achievement_prefixes[Random.rand(achievement_prefixes.length)] % details['name']

    if details.has_key?('tips') && details['tips'].has_key?("groups") && details["tips"]["groups"].length > 0
      tips = details['tips']["groups"].first["items"]

      if tips.length > 0
        description = tips[Random.rand(tips.length)]['text']
      else
        description = "Scraped from FourSquare"
      end
    else
      description = 'Scraped from FourSquare'
    end

    wikipedia_page = Wikipedia.find(details['name'])

    unless wikipedia_page.text.nil? or wikipedia_page.text.include? 'may refer to'
      description = wikipedia_page.text

      description = description.split("== References").first if description.include? "== References"

      description = description.split("== See also").first if description.include? "== See also"

      description = description.split("== External").first if description.include? "== External"

      short_description = description

      short_description = short_description.split('\n') if short_description.include? '\n'
    else
      short_description = 'Automatically created achievement'
      full_description = 'Automatically created achievement'
    end

    a.update_attributes(name: achievement_name,
                        short_description: short_description.truncate(255),
                        full_description: description,
                        is_multiplayer: true,
                        is_global: true,
                        base_points: base_points,
                        kind: type,
                        category: category,
                        mode: mode,
                        has_parents: false,
                        icon: category.icon,
                        user: User.first,
    )
    a.objectives << o unless a.objectives.include? o

    if a.valid?
      puts "| Name: #{a.title}"
      puts "| Short: #{a.short_description}"
      puts "| Desc: #{a.full_description}"
      puts "| Points: #{a.base_points}"
      puts "| -------"
      puts "| Creating Location for " << place["name"] << "..."
      puts "| Setting up objective '#{o.tagline}'"
      a.save
      puts "| Achievement #{a.name} saved with #{a.base_points} points and #{a.objectives.count} objectives"

    else
      puts "Achievement could not be created: "
      puts a.errors.messages
    end
  end
  return {total_updated: total_updated, total_created: total_created}
end