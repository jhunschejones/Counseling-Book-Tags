require 'test_helper'

# bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/controllers/comments_controller_test.rb
class CommentsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :comments, :books

  setup do
    login_as(users(:one))
  end

  test "should create a new comment" do
    before_count = Comment.count
    post "/comments", params: { book: { source: books(:one).source, source_id: books(:one).source_id }, comment: { body: "A nifty new comment!" } }
    assert_response :success
    assert_equal before_count + 1, Comment.count
    assert_equal "A nifty new comment!", Comment.last.body
  end

  test "should update users comment" do
    put "/comments/#{comments(:one).id}", params: { comment: { body: "An updated comment body." } }
    assert_response :success
    assert_equal "An updated comment body.", Comment.find(comments(:one).id).body
  end

  test "should not update another users comment" do
    before_comment = Comment.find(comments(:two).id)
    put "/comments/#{comments(:two).id}", params: { comment: { body: "An updated comment body." } }
    assert_response :internal_server_error
    assert_equal Comment.find(comments(:two).id).body, before_comment.body
  end

  test "should delete users comment" do
    before_count = Comment.count
    delete "/comments/#{comments(:one).id}"
    assert_response :success
    assert_equal before_count - 1, Comment.count
  end

  test "should not delete other users comment" do
    before_count = Comment.count
    delete "/comments/#{comments(:two).id}"
    assert_response :internal_server_error
    assert_equal before_count, Comment.count
  end

  private
    def login_as(user)
      post "/login", params: { email: user.email, password: "secret" }
    end
end
