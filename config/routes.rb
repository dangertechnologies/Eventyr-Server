Eventyr::Application.routes.draw do
  post "/graphql", to: "graphql#execute"
  get "/graphql", to: "graphql#index"
  get "/assets/avatar/:hash", to: "assets#show"
  
  mount ActionCable.server => "/subscriptions"
  mount GraphiQL::Rails::Engine,
  at: "/explore",
  graphql_path: "/graphql"


end
