module BooksHelper
  def search_results_page(page)
    books_path(request.params.slice("title", "author", "isbn", "page").merge(page: page))
  end
end
