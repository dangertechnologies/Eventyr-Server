class UpdateEmailIndexOnUsers < ActiveRecord::Migration[5.2]
    def up
        sql = 'DROP INDEX index_users_on_email'
        #sql << ' ON users' if Rails.env == 'production' # Heroku pg
        ActiveRecord::Base.connection.execute(sql)
    end
end
