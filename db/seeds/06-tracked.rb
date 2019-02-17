# Ensure all users are tracking
if Rails.env.development?
  User.where.not(id: 1).each do |user|

    # Complete 3-5 achievements for each user
    achievements = Achievement.order('RANDOM()').take((Random.rand(5) % 5) + 3)

    achievements.each do |achievement|
      achievement.unlock(user, x: achievement.objectives.first.lat, y: achievement.objectives.first.lng)
    end

    o = Objective.includes(:achievements).where.not(achievements: { id: achievements.pluck(:id) }).order('RANDOM()').first
    user.refresh_suggested_achievements(latitude: o.lat, longitude: o.lng)
  end
end