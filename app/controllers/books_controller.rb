class BooksController < ApplicationController
  def index
    result =
      if params[:title]
        Goodreads.search_by_title(params[:title], params[:page] || 1)
      elsif params[:author]
        Goodreads.search_by_author(params[:author], params[:page] || 1)
      elsif params[:isbn]
        Goodreads.search_by_isbn(params[:isbn], params[:page] || 1)
      else
        raise "Unrecognized search type"
      end
    @books = result[:books]
    @current_page = result[:current_page]
    @total_pages = result[:total_pages]
  end

  def show
    if params[:source] == "goodreads"
      @book = Goodreads.book_details(params[:id])
    else
      raise "Unrecognized source type"
    end
  end
end
