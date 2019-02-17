dir = File.dirname(__FILE__)

achievements = JSON.parse(File.read(File.join(dir, "05-achievements.json")))
objectives = Objective.create!(
  JSON.parse(
    File.read(File.join(dir, "05-objectives.json"))
  ).map do |o|
    o.except("country").merge({
      "country" => Country.find_by(name: o["country"] )
    })
  end
)

achievements.map do |a|
  achievement = Achievement.create!(
    a.except("objectives").merge({
      # Pick a random user in dev mode, otherwise use System
      user_id: Rails.env.development? ? User.where.not(id: User.first.id).order('RANDOM()').first.id : User.first.id
    })
  )
  achievement.objectives << Objective.where(hash_identifier: a["objectives"])
end

