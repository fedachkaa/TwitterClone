require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup 
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      user_params = {name: "", email: "user@invalid", password: "foo", password_confirmation: "bar"}
      post users_path, params: {user: user_params}
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                          email: "user@example.com",
                                          password:              "password",
                                          password_confirmation: "password" } } 
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    #Спроба увійти до активації 
    log_in_as(user)
    assert_not is_logged_in?

    #Невалідний активаційний токен
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?

    #Валідний токен, але неправильна адреса пошти
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    
    #Валідний токен та правильна адреса пошти
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end 
