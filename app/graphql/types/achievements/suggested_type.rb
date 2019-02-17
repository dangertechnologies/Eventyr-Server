module Types
  module Achievements
    class SuggestedType < Types::BaseObject
      description <<-DESC
Suggested Achievements are automatically created for users
by the `refreshSuggested` mutation, which receives a set
of coordinates, and finds all Achievements within range
for the user. 

This is used to provide a list of Achievements the user
should aim to complete in the area, and is important to
be able to provide a way for users to cooperate. Since we
**do not** store any users location, we need to be able
to suggest who a user may want to cooperate with, without
knowing where any user is. We can do this by suggesting
users who have Suggested Achievements in common, since this
means they're in the same area, or at least nearby.

Everytime the client calls `refreshSuggested`, the entire
set of Suggested achievements will be wiped, and re-created,
**unless** the user has marked a Suggested Achievement as
favorite. By marking a Suggested Achievement as favorite,
the user may keep this Achievement around in his or her
suggested-list.
DESC
      field :id, ID, null: false
      field :is_favorite, Boolean, null: false,
      description: "Keep this at the top of the list"
      def is_favorite
        object.pinned == true
      end

      field :achievement, AchievementType, null: false

      field :created_at, Integer, null: false
    end
  end
end