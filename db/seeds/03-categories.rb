[
  {
    id: 1,
    title: 'Culture',
    icon: 'castle',
    points: 18,
    description: 'Experience the culture around you',
    category_id: nil,
  },
  {
    id: 2,
    title: 'Clothes & Fashion', 
    description: 'Try it on', 
    points: 10,
    category_id: nil, 
    icon: 'tshirt-crew'
  },
  {
    id: 3,
    title: 'Food & Culinary', 
    description: 'Tickle your tastebuds!', 
    points: 15,
    category_id: nil, 
    icon: 'restaurant'
  },
  {
    id: 4,
    title: 'Sports & Outdoors', 
    description: 'Immerse yourself', 
    points: 18,
    category_id: nil, 
    icon: 'bike' 
  },                                          
  {
    id: 5,
    title: 'Nature & Wildlife',
    description: 'Connect with the Earth', 
    points: 25,
    category_id: nil, 
    icon: 'pine-tree'
  }
].each do |category|
  Category.find_or_create_by(category)
end