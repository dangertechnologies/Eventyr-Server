User.find_or_create_by!(
  name: "System",
  email: 'system@global',
  sign_in_count: 0,
  role: Role.find_by(name: "Developer"),
  points: 0,
  personal_points: 0,
  auto_share: true,
  authentication_token: 'dqwdoqinff843f39n38nv39v8389g',
  country: Country.find_by(name: 'Norway'),
  scan_radius: 25,
  password: "this-will-not-be-used",
)

demo_user = ::User.find_or_create_by(
  name: 'Demo User',
  email: 'demo@dangertechnologies.com',
  role: Role.find_by(name: "Achiever"),
  personal_points: 0,
  points: 0,
  scan_radius: 50,
  auto_share: false,
  password: SecureRandom.base58(24),
  avatar: Base64.encode64(open("https://i.imgur.com/nXcmqCd.png").read),
)
identity = ::Identity.find_or_create_by(uid: "demo-user", provider: :DEMO, user: demo_user, token: "636a-46b3-9392")

# Create demo users
if Rails.env.development?
  require "open-uri"

  # TODO: Demo users
  12.times do
    person = JSON.parse(open("https://randomuser.me/api/").read)["results"].first

    User.create!(
      name: "#{person["name"]["first"].capitalize} #{person["name"]["last"].capitalize}",
      email: person["email"],
      sign_in_count: 0,
      role: Role.find_by(name: "Achiever"),
      points: 0,
      personal_points: 0,
      auto_share: true,
      authentication_token: 'dqwdoqinff843f39n38nv39v8389g',
      country: Country.find_by(name: 'Norway'),
      scan_radius: 25,
      password: "this-will-not-be-used",
      avatar: Base64.encode64(open(person["picture"]["thumbnail"]).read)
    )
  end
end
