class Types::Social::OauthProviderType < Types::BaseEnum
  description <<-DESC
Supported OAuth providers to authenticate with
DESC
  value :google, "Authenticate with Google", value: :google
  value :demo, "Demo user used by TestFlight only.", value: :demo
end