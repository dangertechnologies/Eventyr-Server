ALLOWED_ORIGINS = if Rails.env.production?
                    [
                      "https://eventyr.dangertechnologies.com",
                    ]
                  else
                    [
                      "https://eventyr.dangertechnologies.com",
                      "127.0.0.1:8888",
                      "http://eventyrdev.dangertechnologies.com:8888",
                    ]
                  end
                  

Rails.application.config.middleware.insert_before 0, Rack::Cors, :debug => true, :logger => (-> {Rails.logger }) do
  allow do
    origins ALLOWED_ORIGINS

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end

Rails.application.config.action_cable.disable_request_forgery_protection = true
