module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected

      def find_verified_user
        if verified_user = User.find_by(id: cookies.signed[:user_id])
          verified_user
        else
          # user = User.create(name: "ゲスト")
          # user.name = "ゲスト#{user.id}"
          # user.save
          # cookies.signed[:user_id] = user.id
          # print(cookies.signed[:user_id])
          # reject_unauthorized_connection
        end
      end

      def session
        cookies.encrypted[Rails.application.config.session_options[:key]]
      end

  end
end
