require 'test_helper'

# bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/controllers/sessions_controller_test.rb
class SessionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "login" do
    https!
    get "/login"
    assert_response :success

    post "/login", params: { email: users(:one).email, password: "secret" }
    follow_redirect!
    assert_equal "/users/#{users(:one).id}", path
  end

  test "logout" do
    login_as(users(:one))
    delete "/logout"
    follow_redirect!
    assert_equal "Succesfully logged out", flash[:notice]
    assert_equal "/login", path
  end

  private
    def login_as(user)
      post "/login", params: { email: user.email, password: "secret" }
    end
end
