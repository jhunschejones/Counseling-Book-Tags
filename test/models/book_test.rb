require 'test_helper'

# `bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/models/book_test.rb`
class BookTest < ActiveSupport::TestCase
  describe "title_keywords" do
    test "ignores special characters and duplicate words" do
      keywords = Book.title_keywords("Harry Potter and the Sourcerer's Stone (Harry Potter Book 1)")
      assert_equal keywords, ["HARRY", "POTTER", "SOURCERERS", "STONE", "BOOK", "1"]
    end
  end

  describe "by_query_params :title" do
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

  describe "by_query_params :author" do
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

  describe "by_query_params :isbn" do
    test "returns books matching one isbn" do
      result = Book.by_query_params({isbn: "1235"})
      assert_equal result[0].title, "Adventures in Ruby"
    end

    test "doesn't return books that have no matching isbns" do
      isbns = Book.by_query_params({isbn: "1235"}).map { |book| book.isbns }.flatten
      refute isbns.include?("222")
    end
  end

  describe "by_query_params unrecognized param" do
    test "raises" do
      exception = assert_raises(RuntimeError) { Book.by_query_params({cover: "image.jpg"}) }
      assert_equal exception.message, "Unrecognized search type"
    end
  end

  describe "find_or_create" do
    test "raises for unrecognized source" do
      exception = assert_raises(RuntimeError) { Book.find_or_create("library", "1") }
      assert_equal exception.message, "Unrecognized source"
    end

    describe "when book does not exist in db" do
      test "creates new book from goodreads" do
        Book.find_or_create("goodreads", 3)
        assert_equal Book.last.source_id, "3"
        assert_equal Book.last.source, "goodreads"
      end

      test "creates new book from openlibrary" do
        Book.find_or_create("openlibrary", "OL82592W")
        assert_equal Book.last.source_id, "OL82592W"
        assert_equal Book.last.source, "openlibrary"
      end
    end

    describe "when book exists in db" do
      setup do
        # Douglas Adams, The Hitchhiker's Guide to the Galaxy
        Book.create_goodreads_book(16)
        # J.K. Rowling, Harry Potter and the Philosopher's Stone
        Book.create_openlibrary_book("OL82592W")
      end

      test "returns existing goodreads book from db" do
        before_count = Book.count
        book = Book.find_or_create("goodreads", 16)
        assert_equal Book.count, before_count
        assert_equal book.title, "The Hitchhiker's Guide to the Galaxy (Hitchhiker's Guide to the Galaxy, #1)"
      end

      test "returns existing openlibrary book from db" do
        before_count = Book.count
        book = Book.find_or_create("openlibrary", "OL82592W")
        assert_equal Book.count, before_count
        assert_equal book.title, "Harry Potter and the Philosopher's Stone"
      end
    end
  end

  describe "database_or_external" do
    test "raises for unrecognized source" do
      exception = assert_raises(RuntimeError) { Book.database_or_external("library", "1") }
      assert_equal exception.message, "Unrecognized source"
    end

    describe "when book does not exist in db" do
      test "returns goodreads book" do
        book = Book.database_or_external("goodreads", 3)
        assert_equal book[:title], "Harry Potter and the Sorcerer's Stone (Harry Potter, #1)"
        assert_nil book[:id] # no :id when not in database
      end

      test "returns openlibrary book" do
        book = Book.database_or_external("openlibrary", "OL82592W")
        assert_equal book[:title], "Harry Potter and the Philosopher's Stone"
        assert_nil book[:id] # no :id when not in database
      end

      test "raises for bad goodreads source_id" do
        exception = assert_raises(RuntimeError) { Book.database_or_external("goodreads", 0) }
        assert_equal exception.message, "Unable to find book with Goodreads id '0'"
      end

      test "raises for bad openlibrary source_id" do
        exception = assert_raises(RuntimeError) { Book.database_or_external("openlibrary", 0) }
        assert_equal exception.message, "Unable to find book with Openlibrary id '0'"
      end
    end

    describe "when book exists in db" do
      setup do
        # Douglas Adams, The Hitchhiker's Guide to the Galaxy
        Book.create_goodreads_book(3)
        # J.K. Rowling, Harry Potter and the Philosopher's Stone
        Book.create_openlibrary_book("OL82592W")
      end

      test "returns goodreads book" do
        book = Book.database_or_external("goodreads", 3)
        assert_equal book[:title], "Harry Potter and the Sorcerer's Stone (Harry Potter, #1)"
        refute_nil book[:id] # :id only exists on valid DB record
      end

      test "returns openlibrary book" do
        book = Book.database_or_external("openlibrary", "OL82592W")
        assert_equal book[:title], "Harry Potter and the Philosopher's Stone"
        refute_nil book[:id] # :id only exists on valid DB record
      end
    end
  end
end
