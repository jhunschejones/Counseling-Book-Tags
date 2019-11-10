module BooksHelper
  def search_results_page(page)
    books_path(request.params.slice("title", "author", "isbn", "page", "source").merge(page: page))
  end

  # Allow toggling searched params, preventing the user from searching
  # duplicate tags or removing the last searched tag
  def toggle_searched_tags(new_tag, params)
    tag_params_string =
      if params[:tags].include?(new_tag) && params[:tags].length == 1
        params[:tags].map { |tag| "&tags[]=#{tag}" }
      elsif params[:tags].include?(new_tag)
        params[:tags].map { |tag| tag == new_tag ? nil : "&tags[]=#{tag}" }.compact
      else
        params[:tags].map { |tag| "&tags[]=#{tag}" }.push("&tags[]=#{new_tag}")
      end
    tag_params_string.unshift("?").join()
  end
end
