class Types::Taxonomy::ModeType < Types::BaseEnum
  Achievement.modes.keys.sort.each do |mode|
    value mode.upcase, Achievement.modes[mode].to_s
  end
end