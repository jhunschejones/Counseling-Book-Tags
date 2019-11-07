class BooksController < ApplicationController
  def index
    return unless book_params.present?

    if book_params[:source] == "goodreads"
      external_api_result = Goodreads.search_by_query_params(book_params)
      @books = external_api_result[:books]
    elsif book_params[:tags]
      @books = Book.by_tags(book_params[:tags])
      @tags = Tag.uniques_from_list_of_books(@books)
    else
      @books = Book.by_query_params(book_params)
    end

    @current_page = external_api_result ? external_api_result[:current_page] : 1
    @total_pages = external_api_result ? external_api_result[:total_pages] : 1
  end

  def show
    raise "Unrecognized source type" unless book_params[:source] == "goodreads"
    @book = Book.database_or_external(book_params[:source], book_params[:id])
    @tags = @book[:id] ? @book.tags : []
    @authors = @book[:authors] ? @book[:authors] : @book.authors
  end

  private
    def book_params
      params.permit(:id, :source, :title, :author, :isbn, tags: [])
    end
end
