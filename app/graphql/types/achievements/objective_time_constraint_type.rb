class Types::Achievements::ObjectiveTimeConstraintType < Types::BaseEnum
  Objective.time_constraints.keys.sort.each do |constraint|
    value constraint.upcase, constraint.to_s, value: constraint
  end
end