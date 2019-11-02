require 'httparty'

module Goodreads
  def self.search_by_title(title)
    response = HTTParty.get("https://www.goodreads.com/search/index.xml?key=#{ENV["GOODREADS_KEY"]}&q=#{title}&search[field]=title&page=1", timeout: 12).parsed_response
    {
      total_results: response["GoodreadsResponse"]["search"]["total_results"].to_i,
      page_start: response["GoodreadsResponse"]["search"]["results_start"].to_i,
      page_end: response["GoodreadsResponse"]["search"]["results_end"].to_i,
      total_pages: (response["GoodreadsResponse"]["search"]["total_results"].to_f / 19).floor,
      books: response["GoodreadsResponse"]["search"]["results"]["work"].map do |book_result|
        {
          goodreads_id: book_result["best_book"]["id"],
          title: book_result["best_book"]["title"],
          author: book_result["best_book"]["author"]["name"],
          published_year: book_result["original_publication_year"].to_i,
          cover_url: book_result["best_book"]["image_url"]
        }
      end
    }
  end

  def self.search_by_author(author)
  end

  def self.search_by_isbn(isbn)
  end

  def self.book_details(book_id)
  end
end
