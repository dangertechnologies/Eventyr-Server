namespace :reset do

  desc "Resets all database settings"

  task database: :environment do
    Notification.all.destroy_all
    SharedList.all.destroy_all
    SharedAchievement.all.destroy_all
    List.all.destroy_all
    Tracked.all.destroy_all
    Unlocked.all.destroy_all
    ObjectiveProgress.all.destroy_all
    Objective.all.destroy_all
    Vote.all.destroy_all
    Achievement.all.destroy_all
    FriendRequest.all.destroy_all
    CoopRequest.all.destroy_all
    Identity.destroy_all
    User.all.destroy_all
    Category.all.destroy_all
    Country.all.destroy_all
    Region.all.destroy_all
    Continent.all.destroy_all
    Role.all.destroy_all
    
  end

end
