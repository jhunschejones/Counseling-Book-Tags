require 'test_helper'

# bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/lib/goodreads_test.rb
class GoodreadsTest < ActiveSupport::TestCase
  setup do
    @hp_one = {
      source_id: 3,
      source: "goodreads",
      title: "Harry Potter and the Sorcerer's Stone (Harry Potter, #1)",
      authors: ["J.K. Rowling"],
      published_year: 1997,
      cover_url: "https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1474154022l/3._SX200_.jpg"
    }
  end

  test "should search by title" do
    search = Goodreads.search_by_title("Harry Potter")
    assert_includes search[:books], @hp_one
  end

  test "should search by author" do
    search = Goodreads.search_by_author("J.K. Rowling")
    assert_includes search[:books], @hp_one
  end
end
