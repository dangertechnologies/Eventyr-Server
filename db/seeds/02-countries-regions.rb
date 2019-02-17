# Set up countries, continents and regions

puts "Creating countries"
ISO3166::Country.all.map do |country|
  puts "#{country.region} / #{country.subregion} / #{country.ioc || country.gec} / #{country.name}"

  continent_name = country.region
  continent_name = country.name if !continent_name || continent_name.blank?
  

  continent = Continent.find_or_create_by!(
    name: continent_name,
  )

  region_name = country.subregion
  region_name = country.region if !region_name || region_name.blank?
  region_name = country.name if !region_name || region_name.blank?

  region = Region.find_or_create_by!(
    name: region_name,
    continent: continent
  )

  # This allows us to perform lookups per country, e.g max lat/lng
  Country.create!(name: country.name, region: region)
end
