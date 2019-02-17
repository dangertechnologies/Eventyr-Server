class Types::Assets::IconType < Types::BaseEnum
  description <<-DESC
  Subset of MaterialCommunityIcons
  DESC
  Achievement.icons.keys.sort.each do |icon|
    value icon.to_s.gsub(/-/, '_'), icon.to_s, value: icon
  end
end