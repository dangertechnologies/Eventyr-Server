module Types
  module Achievements
    class ObjectiveInputType < Types::BaseInputObject
      argument :id, String, required: false
      argument :tagline, String, required: true
      argument :base_points, Float, required: true
      argument :required_count, Integer, required: false
      argument :kind, String, required: true
      argument :lat, Float, required: false
      argument :lng, Float, required: false
      argument :country, String, required: false
    end
  end
end
