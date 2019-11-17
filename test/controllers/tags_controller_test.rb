require 'test_helper'

# bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/controllers/tags_controller_test.rb
class TagsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :tags, :books

  setup do
    login_as(users(:one))
  end

  test "should get all tags page" do
    get "/tags"
    assert_response :success
    assert_select "div.all-tags"
    assert_select "a.tag", 3 # all tags without duplicates
  end

  test "should create a new tag" do
    before_count = Tag.count
    post "/tags", params: { book: { source: books(:one).source, source_id: books(:one).source_id }, tag: { text: "A new tag" } }
    assert_response :success
    assert_equal before_count + 1, Tag.count
    assert_equal "A New Tag", Tag.last.text # tag formated to title case
  end

  test "should create multiple tags" do
    before_count = Tag.count
    post "/tags", params: { book: { source: books(:one).source, source_id: books(:one).source_id }, tag: { text: "Three, New, Tags" } }
    assert_response :success
    assert_equal before_count + 3, Tag.count
  end

  test "should delete users tag" do
    before_count = Tag.count
    delete "/tags/#{tags(:one).id}"
    assert_response :success
    assert_equal before_count - 1, Tag.count
  end

  test "should not delete other users tag" do
    before_count = Tag.count
    delete "/tags/#{tags(:three).id}"
    assert_response :internal_server_error
    assert_equal before_count, Tag.count
  end

  private
    def login_as(user)
      post "/login", params: { email: user.email, password: "secret" }
    end
end
