require 'test_helper'

# bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/models/author_test.rb
class AuthorTest < ActiveSupport::TestCase
  describe "name_keywords" do
    test "ignores special characters" do
      keywords = Author.name_keywords("J. K. Rowling")
      assert_equal ["J", "K", "ROWLING"], keywords
    end

    test "ignores unimportant and duplicate words" do
      keywords = Author.name_keywords("The great great JK Rowling of the UK")
      assert_equal ["GREAT", "JK", "ROWLING", "UK"], keywords
    end
  end
end
