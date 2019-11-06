class BooksController < ApplicationController
  def index
    return unless book_search_params.present?

    if book_search_params[:source] == "goodreads"
      result = Goodreads.search_from_query_params(book_search_params)
      @books = result[:books]
      @current_page = result[:current_page]
      @total_pages = result[:total_pages]
    else
      @books = Book.search_from_query_params(book_search_params)
      @current_page = 1
      @total_pages = 1
    end
  end

  def show
    raise "Unrecognized source type" unless book_search_params[:source] == "goodreads"
    @book = Book.database_or_external(book_search_params[:source], book_params[:id])
    @tags = @book.new_record? ? [] : Tag.where(book_id: @book.id)
  end

  private
    def book_params
      params.permit(:id)
    end

    def book_search_params
      params.permit(:source, :title, :author, :isbn).tap do |params|
        # Only replacing these values for now while manual URL searches include them
        params[:source] = params[:source].gsub("\"", "") if params[:source]
        params[:title] = params[:title].gsub("\"", "") if params[:title]
        params[:author] = params[:author].gsub("\"", "") if params[:author]
      end
    end
end
