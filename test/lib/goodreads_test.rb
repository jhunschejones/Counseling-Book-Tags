require 'test_helper'

# bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/lib/goodreads_test.rb
class GoodreadsTest < ActiveSupport::TestCase
  setup do
    @hp_one = Goodreads::BookSearchResult.new(
      3,
      "goodreads",
      "Harry Potter and the Sorcerer's Stone (Harry Potter, #1)",
      [Goodreads::BookSearchAuthor.new("J.K. Rowling")],
      1997,
      "https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1474154022l/3._SX250_.jpg"
    )
  end

  test "should search by title" do
    search = Goodreads.search_by_title("Harry Potter")
    results_include(search[:books], @hp_one)
  end

  test "should search by author" do
    search = Goodreads.search_by_author("J.K. Rowling")
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
