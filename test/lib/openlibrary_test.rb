require 'test_helper'

# bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/lib/openlibrary_test.rb
class OpenlibraryTest < ActiveSupport::TestCase
  setup do
    @hp_one = Openlibrary::BookSearchResult.new(
      "OL82586W",
      "openlibrary",
      "Harry Potter and the Deathly Hallows",
      [Openlibrary::BookSearchAuthor.new("J. K. Rowling")],
      2005,
      "https://covers.openlibrary.org/b/id/8234415-L.jpg",
    )
  end

  test "should search by title" do
    search = Openlibrary.search_by_title("Harry Potter")
    results_include(search[:books], @hp_one)
  end

  test "should search by author" do
    search = Openlibrary.search_by_author("J.K. Rowling")
    results_include(search[:books], @hp_one)
  end

  private
    def results_include(search_results, book)
      assert_includes search_results.collect { |book| book.authors.collect { |author| author.name }}.flatten, book.authors[0].name
      assert_includes search_results.collect { |book| book.title }, book.title
      assert_includes search_results.collect { |book| book.source_id }, book.source_id
      assert_includes search_results.collect { |book| book.source }, book.source
      assert_includes search_results.collect { |book| book.published_year }, book.published_year
      assert_includes search_results.collect { |book| book.cover_url }, book.cover_url
    end
end
