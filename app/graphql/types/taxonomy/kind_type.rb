class Types::Taxonomy::KindType < Types::BaseEnum
  Achievement.kinds.keys.sort.each do |kind|
    value kind.upcase.gsub(/-/, '_'), Achievement.kinds[kind].to_s
  end
end