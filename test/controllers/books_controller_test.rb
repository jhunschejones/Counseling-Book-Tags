require 'test_helper'

#  bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/controllers/books_controller_test.rb
class BooksControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :books, :authors

  setup do
    login_as(users(:one))
    book_one = Book.find(books(:one).id)
    book_one.authors = book_one.authors << Author.find(authors(:one).id)
    book_one.save!
    book_two = Book.find(books(:two).id)
    book_two.authors = book_two.authors << Author.find(authors(:two).id)
    book_two.save!
  end

  test "should get index" do
    get "/books"
    assert_equal "/books", path
    assert_select "div.book-results"
    assert_select "a.book-card", 2
  end

  test "should get show" do
    get "/books/#{books(:one).source_id}", params: { source: books(:one).source }
    assert_select "p.title", books(:one).title
    assert_select "h2.author", books(:one).authors[0].name
    assert_select "p.published", "First published in #{books(:one).published_year}"
    assert_select "div.description", books(:one).description
  end

  private
    def login_as(user)
      post "/login", params: { email: user.email, password: "secret" }
    end
end
