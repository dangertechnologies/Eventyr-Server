require "capybara"
require "capybara/poltergeist"
require "capybara/dsl"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {js_errors: false, timeout: 60})
end

namespace :achievements do

  desc "Populates the Achievement database by crawling TripAdvisor"

  task :tripadvisor, [:search] => :environment do |task, args|
    include Capybara::DSL
    Capybara.default_driver = :poltergeist
    session = Capybara::Session.new(:poltergeist)
    session.visit "http://www.tripadvisor.com"


    session.fill_in 'mainSearch', with: args.search
    session.execute_script("var c = document.getElementsByTagName('form'); c[1].submit()")

    titles = ["A visit to %s", "A trip to %s", "Stopping at %s", "Arriving at %s", "Seeing %s", "Travelling to %s", "What's %s?", "Getting to %s"]

    if session.has_link?(args.search)
      puts "1. Search has been completed. Attempting to close popup window."


      if Capybara.current_driver == :selenium
        session.driver.browser.switch_to.window(session.driver.browser.window_handles.last)
        session.driver.browser.close
        session.driver.browser.switch_to.window(session.driver.browser.window_handles.first)
      end

      puts "2. Popup window closed. Locating link."

      session.find(:xpath, '//*[@id="SEARCH_RESULTS"]/div[1]/div[3]/div[1]/a').click

      puts "3. Switching to search result window"
      if Capybara.current_driver == :selenium
        session.driver.browser.switch_to.window(session.driver.browser.window_handles.last)
      end

      session.within_window(session.driver.window_handles.last) do
        if session.has_content?("Popular Destinations")
          puts "4. Got details page. Going deeper to collect links"
          while session.has_content?("See more popular destinations in #{args.search}") do
            session.find(:xpath, '//*[@id="BODYCON"]/div[2]/div[4]').click
          end
          puts session.driver.browser.title.split('|').first if Capybara.current_driver == :selenium
          puts session.title.split('|').first if Capybara.current_driver == :poltergeist
          puts "5. Collecting links ... "
          urls = []
          session.all('a.name').each do |a|
            link = "http://www.tripadvisor.com" + a[:href] unless a[:href] =~ /^http:\/\/(www\.|)tripadvisor\.com/
            link ||= a[:href]
            urls << link
            puts "Added %s" % link
          end

          urls.each do |url|
            session.driver.reset!
            session.visit url.to_s
            if session.has_content? "Attractions"

              if Capybara.javascript_driver == :selenium
                city = session.driver.browser.title.split(" ").first
              else
                city = session.title.split(" ").first
              end
              puts "6. Found the following Attractions in %s:"%city
              session.all("li.attractions a").first.click

              attraction_titles = session.all("a.property_title")
              attraction_map_links = session.all(".wrap > .resources > span:first-child")
              count = 0

              attraction_titles.each do |t|
                title = titles[Random.rand(titles.size)]%t.text

                unless Achievement.exists?(name: title) or attraction_map_links.nil? or !attraction_map_links.any?
                  tagline = 'Go to '+t.text+' in '+city
                  next if attraction_map_links.nil? or attraction_map_links[count].nil? or attraction_map_links[count][:onclick].nil?
                  onclick = attraction_map_links[count][:onclick].split(',')

                  coords = Hash.new
                  coords[:x] = onclick[4].to_s.gsub!("'","").to_f
                  coords[:y] = onclick[5].to_s.gsub!("'","").to_f

                  unless coords[:y].nil? or coords[:x].nil? or !coords[:x].is_a? Float or !coords[:y].is_a? Float or coords[:y] == '0.0' or coords[:x] == '0.0' or coords[:x] == 0.0 or coords[:y] == 0.0 or Location.exists?(x: coords[:x], y: coords[:y])

                    puts t.text << " with coordinates " << coords.to_s

                    puts "=========================================="
                    puts "Creating new Achievement: #{title}"
                    puts "=========================================="
                    icon = Icon.find(52)
                    achievement = Achievement.new do |a|
                      a.name = title
                      a.short_description = Faker::Lorem.sentence(10)
                      a.full_description = Faker::Lorem.sentence(10)
                      a.is_multiplayer = true
                      a.has_parents = false
                      a.is_global = true
                      a.is_suggested_global = false
                      a.mode = Mode.find_by_name('Normal')
                      a.category = Category.first
                      a.type = Type.find_by_name('Location')
                      a.base_points = Random.rand(100)+5
                      a.icon = icon
                    end

                    if achievement.valid?
                      puts "| Name: #{achievement.title}"
                      puts "| Short: #{achievement.short_description}"
                      puts "| Desc: #{achievement.full_description}"
                      puts "| Points: #{achievement.base_points}"
                      puts "| -------"
                      puts "| Creating Location for " << t.text << "..."
                      location = Location.create!(x: coords[:x], y: coords[:y], z: 0)
                      puts "| Setting up objective '#{tagline}'"
                      achievement.save
                      achievement.objectives.create(tagline: tagline, base_points: Random.rand(30)+5, required_count: 1, is_public: true, goal: location)
                      puts "| Achievement #{achievement.name} saved with #{achievement.base_points} points and #{achievement.objectives.count} objectives"

                    else
                      puts "Achievement could not be created: "
                      puts achievement.errors.messages
                    end

                    count += 1
                  end
                end
              end

            end
          end
        else
          puts "4. Broken link to details page, or details page content deviation"
        end
      end
    else
      puts "Couldn't find link to the country"
    end
  end

end
