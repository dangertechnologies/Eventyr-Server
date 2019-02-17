class SearchView < ActiveRecord::Migration[5.2]
  def change
    execute "CREATE VIEW searches AS 
            
            SELECT
                achievements.id AS searchable_id,
                'Achievement' AS searchable_type,
                objectives.tagline AS term
            FROM achievements
            JOIN achievements_objectives ON achievements_objectives.achievement_id = achievements.id
            JOIN objectives ON objectives.id = achievements_objectives.objective_id
    
            UNION
    
            SELECT
                achievements.id AS searchable_id,
                'Achievement' AS searchable_type,
                achievements.name AS term
            FROM achievements
    
            UNION
    
            SELECT achievements.id AS searchable_id,
                'Achievement' AS searchable_type,
                achievements.short_description AS term
            FROM achievements
    
            UNION
    
            SELECT achievements.id AS searchable_id,
                'Achievement' AS searchable_type,
                objectives.lat || ',' || objectives.lng AS term
            FROM achievements
            JOIN achievements_objectives ON achievements_objectives.achievement_id = achievements.id
            JOIN objectives ON achievements_objectives.objective_id = objectives.id

            UNION

            SELECT users.id AS searchable_id,
                'User' AS searchable_type,
                users.email AS term
            FROM users

            UNION

            SELECT users.id AS searchable_id,
                'User' AS searchable_type,
                users.name AS term
            FROM users

            UNION

            SELECT lists.id AS searchable_id,
                'List' AS searchable_type,
                lists.title AS term
            FROM lists"
    execute "CREATE INDEX index_achievements_on_full_description ON achievements USING gin(to_tsvector('english',full_description));"
    execute "CREATE INDEX index_achievements_on_short_description ON achievements USING gin(to_tsvector('english', short_description));"
    execute "CREATE INDEX index_achievements_on_name ON achievements USING gin(to_tsvector('english',name));"
    execute "CREATE INDEX index_users_on_email ON users USING gin(to_tsvector('english',email));"
    execute "CREATE INDEX index_users_on_name ON users USING gin(to_tsvector('english',name));"
    execute "CREATE INDEX index_lists_on_title ON lists USING gin(to_tsvector('english',title));"
                
  end
end
