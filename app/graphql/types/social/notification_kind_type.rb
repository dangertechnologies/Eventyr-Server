class Types::Social::NotificationKindType < Types::BaseEnum
  Notification.kinds.keys.sort.each do |kind|
    value kind.upcase, Notification.kinds[kind].to_s
  end
end