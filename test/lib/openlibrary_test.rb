require 'test_helper'

# bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/lib/openlibrary_test.rb
class OpenlibraryTest < ActiveSupport::TestCase
  setup do
    @hp_one = {
      source_id: "OL16313124W",
      source: "openlibrary",
      title: "Harry Potter and the Chamber of Secrets",
      published_year: 1998,
      cover_url: "https://covers.openlibrary.org/b/id/8108733-L.jpg",
      authors: ["J. K. Rowling"]
    }
  end

  test "should search by title" do
    search = Openlibrary.search_by_title("Harry Potter")
    assert_includes search[:books], @hp_one
  end

  test "should search by author" do
    search = Openlibrary.search_by_author("J.K. Rowling")
    assert_includes search[:books], @hp_one
  end
end
