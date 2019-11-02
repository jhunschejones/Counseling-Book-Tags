require 'test_helper'

class TagsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get "/tags"
    assert_response :success
  end

  test "should get create" do
    post "/tags"
    assert_response :success
  end

  test "should get destroy" do
    delete "/tags/1"
    assert_response :success
  end

end
