module UsersHelper
  def log_in(user)
    session[:user_id] = user.id
    cookies.signed[:user_id] = user.id
  end

  def current_user?(user)
    user == current_user
  end

  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  def new_user_setting
    @user = User.create(name: "ゲスト")
    @user.name = "ゲスト#{@user.id}"
    @user.save
  end
end
