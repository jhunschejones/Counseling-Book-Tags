require 'test_helper'

# bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/models/comment_test.rb
class CommentTest < ActiveSupport::TestCase
  fixtures :comments, :users

  describe "html_safe_body" do
    test "replaces newlines with <br /> tags" do
      expected_body = "This comment<br /><br />has quite a few<br /><br />short paragraphs."
      comment = Comment.new(body: "This comment\n\nhas quite a few\n\n\nshort paragraphs.")
      comment.html_safe_body
      assert_equal expected_body, comment.body
    end

    test "allows single quotes" do
      comment = Comment.new(body: "This 'comment' has 'single' quotes.")
      comment.html_safe_body
      assert_equal "This 'comment' has 'single' quotes.", comment.body
    end

    test "allows double quotes" do
      comment = Comment.new(body: 'This "comment" has literal "double" quotes.')
      comment.html_safe_body
      assert_equal 'This "comment" has literal "double" quotes.', comment.body
    end

    test "escapes javascript" do
      expected_body = "Sneaking some <script>alert(\"javascript\")<\\/script> in here."
      comment = Comment.new(body: "Sneaking some <script>alert(\"javascript\")</script> in here.")
      comment.html_safe_body
      assert_equal expected_body, comment.body
    end
  end

  describe "sanitize_body" do
    test "remove trailing spaces and html tags" do
      comment = Comment.new(body: "This <i>comment</i> has some <br /><br />html tags.  ")
      comment.send(:sanitize_body)
      assert_equal "This comment has some html tags.", comment.body
    end
  end

  describe "success_response" do
    test "formats json api response" do
      expected_response = {
        data: {
          id: comments(:one).id,
          type: "comment",
          attributes: {
            body: "This book was definitly my favorite",
            createdAt: comments(:one).created_at.localtime.to_formatted_s(:long_ordinal)
          },
          relationships: {
            user: {
              data: {
                id: users(:one).id,
                type: "user",
                attributes: {
                  name: users(:one).name
                }
              }
            }
          }
        }
      }
      assert_equal expected_response, comments(:one).success_response
    end
  end
end
