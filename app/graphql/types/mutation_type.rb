module Types
  class MutationType < BaseQuery
    
    field :createAchievement, mutation: Mutations::Achievements::Create
    field :updateAchievement, mutation: Mutations::Achievements::Update
    field :deleteAchievement, mutation: Mutations::Achievements::Delete
    field :addFriend,         mutation: Mutations::Friends::AddFriend
    field :removeFriend,      mutation: Mutations::Friends::RemoveFriend
    field :refreshSuggested,  mutation: Mutations::Achievements::RefreshSuggested
    field :completeObjective, mutation: Mutations::Achievements::CompleteObjective
    field :createList,        mutation: Mutations::Lists::CreateList
    field :updateList,        mutation: Mutations::Lists::UpdateList
    field :addToList,         mutation: Mutations::Lists::AddToList
    field :removeFromList,    mutation: Mutations::Lists::RemoveFromList
    field :acceptFriend,      mutation: Mutations::Friends::AcceptFriend
    field :rejectFriend,      mutation: Mutations::Friends::RejectFriend
    field :requestCoop,       mutation: Mutations::Cooperations::RequestCoop
    field :acceptCoop,        mutation: Mutations::Cooperations::AcceptCoop
    field :rejectCoop,        mutation: Mutations::Cooperations::RejectCoop
    field :upvote,            mutation: Mutations::Achievements::Upvote
    field :downvote,          mutation: Mutations::Achievements::Downvote
    field :authenticateUser,  mutation: Mutations::Users::AuthenticateUser
    field :shareAchievement,  mutation: Mutations::Share::ShareAchievement
    field :shareList,         mutation: Mutations::Share::ShareList
    field :followList,        mutation: Mutations::Share::FollowList
    field :rejectList,        mutation: Mutations::Share::RejectList
    field :updateMe,          mutation: Mutations::Users::UpdateMe
  end
end