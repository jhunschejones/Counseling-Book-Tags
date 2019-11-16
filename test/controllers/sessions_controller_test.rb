require 'test_helper'

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
end
