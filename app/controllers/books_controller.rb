class BooksController < ApplicationController
  def index
    if book_params[:source] == "goodreads"
      external_api_result = Goodreads.search_by_query_params(book_params)
      @books = external_api_result[:books]
      @current_page = external_api_result[:current_page]
      @total_pages = external_api_result[:total_pages]
    elsif book_params[:tags]
      @books = Book.by_tags(book_params[:tags])
      all_tags = Tag.uniques_from_list_of_books(@books)
      @searched_tags = all_tags.select { |tag| book_params[:tags].include?(tag.text) }.sort
      @other_tags = all_tags.select { |tag| !book_params[:tags].include?(tag.text) }.sort
    elsif book_params.present?
      @books = Book.by_query_params(book_params)
    end

    if !book_params.present? || @books.length == 0 || (!@books[0] && @books.length == 1)
      redirect_to books_search_path, notice: "No books matched that search"
    end
  end

  def show
    raise "Unrecognized source type" unless book_params[:source] == "goodreads"
    @book = Book.database_or_external(book_params[:source], book_params[:id])
    @tags = @book[:id] ? @book.tags.order(:text) : []
    @authors = @book[:authors] ? @book[:authors] : @book.authors
  end

  def search
  end

  private
    def book_params
      params.permit(:id, :source, :title, :author, :isbn, tags: [])
    end
end
