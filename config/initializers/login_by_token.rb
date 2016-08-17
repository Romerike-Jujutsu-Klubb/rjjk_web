# frozen_string_literal: true
require 'rack/request'
module LoginByToken
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      req = ActionDispatch::Request.new env
      params = ::Rack::Request.new(env).params
      session = req.session
      cookies = req.cookie_jar

      if (k = params['key'])
        if (um = UserMessage.includes(:user).where(key: CGI.unescape(k)).first) && um.user
          session[:user_id] = um.user_id
          cookies.permanent.signed[:user_id] = um.user_id
          req.delete_param('key')
          um.update!(read_at: Time.now)
          logger.info "User #{um.user.name} (#{um.user_id}) logged in by key."
        end
      end
      @app.call(env)
    end
  end
end
Rails.application.config.middleware.use LoginByToken::Rack
