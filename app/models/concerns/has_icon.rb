module HasIcon
  extend ActiveSupport::Concern

  included do
    enum icon: [
      'flag-variant',
      'restaurant',
      'airballoon',
      'airport',
      'anchor',
      'anvil',
      'bank',
      'baseball',
      'baby-buggy',
      'barcode-scan',
      'basketball',
      'beach',
      'bike',
      'binoculars',
      'bone',
      'boombox',
      'bowling',
      'bow-tie',
      'bridge',
      'briefcase',
      'brain',
      'buddhism',
      'bus',
      'bus-clock',
      'bus-double-decker',
      'cake',
      'cake-variant',
      'camera',
      'camera-iris',
      'candle',
      'candycane',
      'car',
      'car-convertible',
      'car-limousine',
      'caravan',
      'cards',
      'cards-outline',
      'cards-club',
      'cards-diamond',
      'cards-heart',
      'cards-spade',
      'carrot',
      'cash',
      'cassette',
      'castle',
      'cat',
      'cctv',
      'ceiling-light',
      'certificate',
      'chess-knight',
      'chili-mild',
      'chili-hot',
      'chip',
      'christianity',
      'church',
      'city',
      'cloud',
      'coffee',
      'coffee-outline',
      'coffee-to-go',
      'corn',
      'cookie',
      'crane',
      'cow',
      'creation',
      'cube-send',
      'cube-outline',
      'cup',
      'earth',
      'duck',
      'dumbbell',
      'elevator',
      'escalator',
      'face',
      'feather',
      'factory',
      'fan',
      'fire-truck',
      'fish',
      'flower',
      'football-helmet',
      'forklift',
      'fountain',
      'gift',
      'gondola',
      'golf',
      'hammer',
      'hanger',
      'headphones',
      'hook',
      'ice-cream',
      'human-male-female',
      'human-male',
      'human-female',
      'infinity',
      'incognito',
      'islam',
      'judaism',
      'knife-military',
      'lamp',
      'ladybug',
      'key-variant',
      'leaf',
      'lifebuoy',
      'lead-pencil',
      'matrix',
      'map-outline',
      'motorbike',
      'muffin',
      'music',
      'ninja',
      'oil',
      'owl',
      'panda',
      'palette',
      'pig',
      'pier-crane',
      'pill',
      'pillar',
      'pickaxe',
      'pipe',
      'poker-chip',
      'pokeball',
      'pool',
      'popcorn',
      'qrcode-scan',
      'run',
      'rocket',
      'scale-balance',
      'scale',
      'seat-individual-suite',
      'shower',
      'sign-direction',
      'snowflake',
      'snowman',
      'pine-tree',
      'soccer',
      'spray',
      'stadium',
      'summit',
      'sunglasses',
      'swim',
      'sword',
      'taxi',
      'tent',
      'tennis',
      'tie',
      'routes',
      'road-variant',
      'toilet',
      'tram',
      'train',
      'tractor',
      'tooth',
      'tshirt-crew',
      'van-utility',
      'voice',
      'watch',
      'water',
      'weather-sunset',
      'worker',
      'yin-yang' 
    ]
  end

end