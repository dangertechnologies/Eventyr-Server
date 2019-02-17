class Mutations::Achievements::Create < Mutations::BaseMutation
  requires_authentication
  
  argument :name, String, required: true
  argument :description, String, required: true
  argument :icon, Types::Assets::IconType, required: true
  argument :objectives, [Types::Achievements::ObjectiveInputType], required: true
  argument :mode, Types::Taxonomy::ModeType, required: true
  argument :category_id, Integer, required: true
  

  field :achievement, Types::Achievements::AchievementType, null: true
  field :errors, [String], null: false

  def resolve(name: nil, description: nil, icon: nil, objectives: [], mode: nil, category_id: nil)
    # Find category and modes first
    category = ::Category.find(category_id)

    # Create all objectives
    objectives = objectives.map do |objective|
                  if objective[:id] && !objective[:id].blank?
                    o = ::Objective.find(objective[:id])
                  else
                    o = ::Objective.new(
                      objective.to_h.except(:country)
                    )
                  end

                  o.kind = "LOCATION" if objective[:lat] && objective[:lng]
                  o.required_count = 1 if objective[:required_count].nil? && o.required_count.nil?
                  o.country = Country.find_by(name: objective[:country]) if objective[:country] && o.country.nil?

                  # Ensure validity
                  raise ::ActiveRecord::RecordInvalid.new(o) unless o.valid?
                  o
                 end

    count_locations = objectives.map{ |o| o.kind == "LOCATION" ? 1 : 0 }.sum

    if count_locations > 1
      kind = "DISCOVERY"
    elsif count_locations > 0
      kind = "LOCATION"
    else
      kind = "ACTION"
    end
    
    # Create the Achievement
    achievement = Achievement.new(
      name: name,
      short_description: description.split('\n').first.truncate(100, separator: /\s/),
      full_description: description,
      base_points: Random.rand(15..30),
      mode: mode,
      category: category,
      kind: kind,
      icon: icon,
      user: context[:current_user]
    )

    raise ::ActiveRecord::RecordInvalid.new(achievement) unless achievement.valid?

    # If everything is valid now, create Achievement and attach objectives

    achievement.save!
    objectives.map(&:save)
    achievement.objectives << objectives

    #achievement.save!
    # Successful creation, return the created object with no errors
    {
      achievement: achievement,
      errors: [],
    }

  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      achievement: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      achievement: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      achievement: nil,
      errors: [ error.message ]
    }
  end
end