module SessionsHelper

  #вхід для даного користувача
  def log_in(user)
    session[:user_id] = user.id
  end

  #Запам'ятовування користувача в постійну сесію
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  #повертає даного користувача, який увійшов(якщо такий є)
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  #повертає true, якщо користувач зайшов, інакше - false
  def logged_in?
    !current_user.nil?
  end

  #Забути постійну сесію
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  #вихід користувача
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

end
