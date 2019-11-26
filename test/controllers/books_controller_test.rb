require 'test_helper'

#  bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/controllers/books_controller_test.rb
class BooksControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :books, :authors

  describe "index" do
    setup do
      login_as(users(:one))
      book_one = Book.find(books(:one).id)
      book_one.authors = book_one.authors << Author.find(authors(:one).id)
      book_one.save!
      book_two = Book.find(books(:two).id)
      book_two.authors = book_two.authors << Author.find(authors(:two).id)
      book_two.save!
    end

    test "displays all books" do
      get "/books"
      assert_response :success
      assert_equal "/books", path
      assert_select "div.book-results"
      assert_select "a.book-card", 2
    end
  end

  describe "show" do
    describe "for database book" do
      setup do
        login_as(users(:one))
        book_one = Book.find(books(:one).id)
        book_one.authors = book_one.authors << Author.find(authors(:one).id)
        book_one.save!
      end

      test "displays book details" do
        get "/books/#{books(:one).source_id}", params: { source: books(:one).source }
        assert_response :success
        assert_select "p.title", books(:one).title
        assert_select "h2.author", books(:one).authors[0].name
        assert_select "p.published", "First published in #{books(:one).published_year}"
        assert_select "div.description", books(:one).description
      end
    end

    describe "for external book" do
      test "displays goodreads book details" do
        login_as(users(:one))
        get "/books/136251?source=goodreads"
        assert_show_completed_successfully
      end

      test "displays openlibrary book details" do
        login_as(users(:one))
        get "/books/OL82586W?source=openlibrary"
        assert_show_completed_successfully
      end
    end
  end

  describe "title search" do
    test "returns database books" do
      login_as(users(:one))
      book_one = Book.find(books(:one).id)
      book_one.authors = book_one.authors << Author.find(authors(:one).id)
      book_one.save!

      get "/books?title=squirrels"
      assert_search_completed_successfully
    end

    describe "with covers" do
      test "returns goodreads books" do
        login_as(users(:one))
        get "/books?title=counseling&source=goodreads"
        assert_search_completed_successfully
      end

      test "returns openlibrary books" do
        login_as(users(:one))
        get "/books?title=counseling&source=openlibrary"
        assert_search_completed_successfully
      end
    end

    describe "without covers" do
      test "returns goodreads books" do
        login_as(users(:one))
        get "/books?without_covers=true&title=counseling&source=goodreads"
        assert_search_completed_successfully
      end

      test "returns openlibrary books" do
        login_as(users(:one))
        get "/books?without_covers=true&title=counseling&source=openlibrary"
        assert_search_completed_successfully
      end
    end
  end

  describe "author search" do
    test "returns database books" do
      login_as(users(:one))
      book_one = Book.find(books(:one).id)
      book_one.authors = book_one.authors << Author.find(authors(:one).id)
      book_one.save!

      get "/books?author=author%20one"
      assert_search_completed_successfully
    end

    describe "with covers" do
      test "returns goodreads books" do
        login_as(users(:one))
        get "/books?author=rowling&source=goodreads"
        assert_search_completed_successfully
      end

      test "returns openlibrary books" do
        login_as(users(:one))
        get "/books?author=rowling&source=openlibrary"
        assert_search_completed_successfully
      end
    end

    describe "without covers" do
      test "returns goodreads books" do
        login_as(users(:one))
        get "/books?without_covers=true&author=rowling&source=goodreads"
        assert_search_completed_successfully
      end

      test "returns openlibrary books" do
        login_as(users(:one))
        get "/books?without_covers=true&author=rowling&source=openlibrary"
        assert_search_completed_successfully
      end
    end
  end

  describe "isbn search" do
    test "returns database books" do
      login_as(users(:one))
      book_one = Book.find(books(:one).id)
      book_one.authors = book_one.authors << Author.find(authors(:one).id)
      book_one.save!

      get "/books?isbn=#{books(:one).isbns[0]}"
      assert_search_completed_successfully
    end

    describe "with covers" do
      test "returns goodreads books" do
        login_as(users(:one))
        get "/books?isbn=9780545010221&source=goodreads"
        assert_search_completed_successfully
      end

      test "returns openlibrary books" do
        login_as(users(:one))
        get "/books?isbn=9780545010221&source=openlibrary"
        assert_search_completed_successfully
      end
    end

    describe "without covers" do
      test "returns goodreads books" do
        login_as(users(:one))
        get "/books?without_covers=true&isbn=9780545010221&source=goodreads"
        assert_search_completed_successfully
      end

      test "returns openlibrary books" do
        login_as(users(:one))
        get "/books?without_covers=true&isbn=9780545010221&source=openlibrary"
        assert_search_completed_successfully
      end
    end
  end

  private
    def login_as(user)
      post "/login", params: { email: user.email, password: "secret" }
    end

    def assert_search_completed_successfully
      assert_response :success
      assert_select "div.book-results"
      assert_select "a.book-card"
    end

    def assert_show_completed_successfully
      assert_response :success
      assert_select "p.title"
      assert_select "h2.author"
      assert_select "p.published"
      assert_select "div.description"
    end
end
