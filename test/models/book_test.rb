require 'test_helper'

# `bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/models/book_test.rb`
class BookTest < ActiveSupport::TestCase
  test "title_keywords ignores special characters and duplicate words" do
    keywords = Book.title_keywords("Harry Potter and the Sourcerer's Stone (Harry Potter Book 1)")
    assert_equal keywords, ["HARRY", "POTTER", "SOURCERERS", "STONE", "BOOK", "1"]
  end

  describe "by_query_params title search" do
    test "works with extra words" do
      result = Book.by_query_params({title: "Adventures in the Land of Ruby"})
      assert_equal result[0].title, "Adventures in Ruby"
    end

    test "works with missing words" do
      result = Book.by_query_params({title: "Ruby"})
      assert_equal result[0].title, "Adventures in Ruby"
    end

    test "does not return books that do not match" do
      titles = Book.by_query_params({title: "Adventures in Ruby"}).map { |book| book.title }
      refute titles.include?("Counseling 101")
    end
  end

  describe "by_query_params author search" do
    setup do
      # J.K. Rowling, Harry Potter and the Sorcerer's Stone
      Book.create_goodreads_book(3)
      # Douglas Adams, The Hitchhiker's Guide to the Galaxy
      Book.create_goodreads_book(16)
    end

    test "works with extra words" do
      result = Book.by_query_params({author: "J.K. Rowling The Great"})
      assert_equal result[0].authors[0].name, "J.K. Rowling"
    end

    test "works with missing words" do
      result = Book.by_query_params({author: "Rowling"})
      assert_equal result[0].authors[0].name, "J.K. Rowling"
    end

    test "does not return books that do not match" do
      author_names = Book.by_query_params({author: "J.K. Rowling The Great"}).map { |book| book.authors[0].name }
      refute author_names.include?("Douglas Adams")
    end
  end

  describe "by_query_params isbn search" do
    test "returns books matching one isbn" do
      result = Book.by_query_params({isbn: "1235"})
      assert_equal result[0].title, "Adventures in Ruby"
    end

    test "doesn't return books that have no matching isbns" do
      isbns = Book.by_query_params({isbn: "1235"}).map { |book| book.isbns }.flatten
      refute isbns.include?("222")
    end
  end
end
