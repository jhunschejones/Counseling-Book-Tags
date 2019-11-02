require 'test_helper'

class BooksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get "/books"
    assert_response :success
  end

  test "should get show" do
    get "/books/1"
    assert_response :success
  end

end
