require 'test_helper'

class GoodreadsTest < ActiveSupport::TestCase
  test "should search by title" do
    search = Goodreads.search_by_title("Harry Potter")
    hp_one = {goodreads_id: 3, title: "Harry Potter and the Sorcerer's Stone (Harry Potter, #1)", author: "J.K. Rowling", published_year: 1997, cover_url: "https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1474154022l/3._SX98_.jpg"}
    assert_includes search[:books], hp_one
  end
end
