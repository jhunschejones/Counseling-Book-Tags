require 'httparty'

module Goodreads
  def self.search_by_title(title, page=1)
    Rails.cache.fetch("title:#{title}:page:#{page}") do
      response = HTTParty.get("https://www.goodreads.com/search/index.xml?key=#{ENV["GOODREADS_KEY"]}&q=#{title}&search[field]=title&page=#{page}", timeout: 12).parsed_response
      transform_book_results(response, page)
    end
  end

  def self.search_by_author(author, page=1)
    Rails.cache.fetch("author:#{author}:page:#{page}") do
      response = HTTParty.get("https://www.goodreads.com/search/index.xml?key=#{ENV["GOODREADS_KEY"]}&q=#{author}&search[field]=author&page=#{page}", timeout: 12).parsed_response
      p response
      transform_book_results(response, page)
    end
  end

  def self.search_by_isbn(isbn, page=1)
    Rails.cache.fetch("isbn:#{isbn}:page:#{page}") do
      response = HTTParty.get("https://www.goodreads.com/search/index.xml?key=#{ENV["GOODREADS_KEY"]}&q=#{isbn}&search[field]=isbn&page=#{page}", timeout: 12).parsed_response
      transform_book_results(response, page)
    end
  end

  def self.book_details(book_id)
    Rails.cache.fetch("book_id:#{book_id}") do
      response = HTTParty.get("https://www.goodreads.com/book/show.xml?key=#{ENV["GOODREADS_KEY"]}&id=#{book_id}", timeout: 12).parsed_response
      book = response["GoodreadsResponse"]["book"]
      authors =
        if book["authors"]["author"].kind_of?(Array)
          book["authors"]["author"].map do |author|
            author["name"] if !author["role"] # only return authors, not other roles like illustrator
          end.compact
        else
          # `authors` is stored as an array
          [
            book["authors"]["author"]["name"]
          ]
        end
      {
        goodreads_id: book["id"],
        title: book["title"],
        authors: authors,
        isbn: book["isbn"].to_i,
        isbn13: book["isbn13"].to_i,
        published_year: book["publication_year"],
        publisher: book["publisher"],
        #
        # "image_url" field ends like `3._SX98_.jpg`. This string can be adjusted to
        # return different size images. Values and their meanings are as follows:
        #
        # - `SX` is size on the x-axis
        # - `SY` is size on the y-axis
        # - `98` is the size in pixels
        #
        cover_url: book["image_url"].gsub(/_\w{2}\d{1,3}_/, "_SX250_"),
        description: format_description(book["description"]),
        language: book["language_code"]
      }
    end
  end

  def self.format_description(description)
    description
      .gsub(/(<br \/>){1,3}/, "<br /><br />") # only include break tags in sets of 2
      .gsub(/<i>|<\/i>/, "\"") # use quotes instead of <i> tags
      .gsub("--back cover", "") # remove source citation
      .split("Source: <")[0] # remove source citation
      .gsub(/--\w*.com$/, "") # remove source citation
  end

  def self.transform_book_results(results, current_page)
    if results["GoodreadsResponse"]["search"]["total_results"].to_i == 0
      {
        total_results: 0,
        current_page: 1,
        page_start: 0,
        page_end: 0,
        total_pages: 1,
        books: []
      }
    else
      {
        total_results: results["GoodreadsResponse"]["search"]["total_results"].to_i,
        current_page: current_page.to_i,
        page_start: results["GoodreadsResponse"]["search"]["results_start"].to_i,
        page_end: results["GoodreadsResponse"]["search"]["results_end"].to_i,
        total_pages: (results["GoodreadsResponse"]["search"]["total_results"].to_f / 19).floor,
        books: results["GoodreadsResponse"]["search"]["results"]["work"].map do |book_result|
          # do not return books without a photo
          book_result["best_book"]["image_url"].include?("nophoto") ? nil :
            {
              goodreads_id: book_result["best_book"]["id"],
              title: book_result["best_book"]["title"],
              author: book_result["best_book"]["author"]["name"],
              published_year: book_result["original_publication_year"].to_i,
              #
              # "image_url" field ends like `3._SX98_.jpg`. This string can be adjusted to
              # return different size images. Values and their meanings are as follows:
              #
              # - `SX` is size on the x-axis
              # - `SY` is size on the y-axis
              # - `98` is the size in pixels
              #
              cover_url: book_result["best_book"]["image_url"].gsub(/_\w{2}\d{1,3}_/, "_SX200_")
            }
        end.compact
      }
    end
  end
end
