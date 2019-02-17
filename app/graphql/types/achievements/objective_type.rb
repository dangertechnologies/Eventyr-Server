module Types
  module Achievements
    class ObjectiveType < Types::BaseObject
      description <<-DESC
An objective is any one individual action that must
be completed in an Achievement. You could say any
given objective is /one/ action that has to be
done by the user, while an Achievement may requires
a user to complete /many/ actions for it to be
achieved.

An example of this would be an Achievement like
"Tom Waits-løpet", that may have 20 objectives, one
for each pub the user must visit on that specific
day to have successfully completed the Achievement.

Objectives themselves dont have any descriptions,
since the Objective.tagline should always be short
and to-the-point, and it should be clear what needs
to be done in a single line of text.

### Kinds
Objectives can either be location based, such as
visiting a place, reaching a mountain top, or in
general just going somewhere; or they can be action
oriented, like performing a dance, cooking a meal,
or anything else. Action oriented objectives should
(in the future) require some sort of verification,
because while we can verify that a user has gone
to the given coordinates, there's no way for us to
automatically complete objectives where a user does
something (unless we e.g integrate with fitness trackers).

These kinds of objectives will require the user to
manually complete them by clicking "Done", and should
require uploading a photo, or similar.

### Time constraints
Objectives may be time constrained, which means they
can only be completed on certain days of the week, 
certain months, or in a given time period. For example,
an objective for "Visit Santa Claus at Oslo City" may
only be available during December each year, while
"Visit Bygdøy Beach" may only be available between May
and August.

Objective.timeConstraint defines what sort of constraint
should be applied using Objective.toTimestamp and
Objective.fromTimestamp, and may be one of:
- NONE: No time constraint
- BETWEEN_TIMESTAMP_MONTHS: Only the months (but any year)
- BETWEEN_TIMESTAMP_HOURS: Only the given hours (but any day)
- BETWEEN_TIMESTAMP_DAYS: Specific date range
- BETWEEN_TIMESTAMP_WEEKDAYS: Only the given weekday range, any week
- BETWEEN_TIMESTAMP_EXACT: Exactly this time range, down to the minute
DESC
      field :id, ID, null: false
      field :tagline, String, null: false,
      description: 'A short and concise instruction of what should be done'
      field :base_points, Float, null: false,
      description: 'How many additional points does completing this objective yield on an Achievement?'
      field :is_public, Boolean, null: false,
      description: 'Visible to everybody?'
      field :required_count, Integer, null: true,
      description: "How many times does the user need to do this?"
      field :kind, String, null: false,
      description: "One of: %s" % Objective.kinds.keys.sort.join(", ")

      field :lat, Float, null: true,
      description: "Latitude to visit for location objectives - otherwise null"
      field :lng, Float, null: true,
      description: "Longitude to visit for location objectives - otherwise null"
      field :altitude, Float, null: true,
      description: "NOT IMPLEMENTED: Altitude to reach on these coordinates."
      field :country, Locations::CountryType, null: true,
      description: "Which country is this objective in? Normalized from coordinates."
      field :fromTimestamp, Integer, null: true,
      description: "Time Constraint: From what time can this objective be completed?"
      field :toTimestamp, Integer, null: true,
      description: "Time Constraint: to what time can this objective be completed?"
      field :timeConstraint, Types::Achievements::ObjectiveTimeConstraintType, null: true,
      description: "Time Constraint: How should to/fromTimestamp be used?"

      field :created_at, Integer, null: false
      field :achievements, [AchievementType], null: true,
      description: "All Achievements this Objective is part of. Completing an objective may unlock multiple Achievements"
    end
  end
end
