require 'httparty'

module Goodreads
  class BookNotFound < StandardError; end
  class UnrecognizedSearchType < StandardError; end

  def self.search_by_title(title, page=1)
    Rails.cache.fetch("source:goodreads:title:#{title}:page:#{page}") do
      response = HTTParty.get("https://www.goodreads.com/search/index.xml?key=#{ENV["GOODREADS_KEY"]}&q=#{title}&search[field]=title&page=#{page}", timeout: 12).parsed_response
      format_book_results(response, page)
    end
  end

  def self.search_by_author(author, page=1)
    Rails.cache.fetch("source:goodreads:author:#{author}:page:#{page}") do
      response = HTTParty.get("https://www.goodreads.com/search/index.xml?key=#{ENV["GOODREADS_KEY"]}&q=#{author}&search[field]=author&page=#{page}", timeout: 12).parsed_response
      format_book_results(response, page)
    end
  end

  # Goodreads API appears to only work with ISBN13?
  def self.search_by_isbn(isbn, page=1)
    Rails.cache.fetch("source:goodreads:isbn:#{isbn}:page:#{page}") do
      response = HTTParty.get("https://www.goodreads.com/search/index.xml?key=#{ENV["GOODREADS_KEY"]}&q=#{isbn}&search[field]=isbn&page=#{page}", timeout: 12).parsed_response
      format_book_results(response, page)
    end
  end

  def self.book_details(book_id)
    Rails.cache.fetch("source:goodreads:book_id:#{book_id}") do
      response = HTTParty.get("https://www.goodreads.com/book/show.xml?key=#{ENV["GOODREADS_KEY"]}&id=#{book_id}", timeout: 12).parsed_response
      raise BookNotFound if response["error"] == "Page not found"
      book = response["GoodreadsResponse"]["book"]
      authors =
        if book["authors"]["author"].kind_of?(Array)
          book["authors"]["author"].map { |author| format_author(author) }.compact
        else
          # `authors` is returned as an array
          [format_author(book["authors"]["author"])]
        end

      {
        source_id: book["id"],
        source: "goodreads",
        title: book["title"],
        authors: authors,
        # isbn: book["isbn"].to_i,
        # isbn13: book["isbn13"].to_i,
        isbns: [book["isbn"], book["isbn13"]],
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
        language: book["language_code"],
      }
    end
  end

  def self.search_by_query_params(params)
    if params[:title]
      Goodreads.search_by_title(params[:title], params[:page] || 1)
    elsif params[:author]
      Goodreads.search_by_author(params[:author], params[:page] || 1)
    elsif params[:isbn]
      Goodreads.search_by_isbn(params[:isbn], params[:page] || 1)
    else
      raise UnrecognizedSearchType
    end
  end

  def self.format_author(author)
    if !author["role"] # only return authors, not other roles like illustrator
      image =
        if author["image_url"]["nophoto"] == "false"
          author["image_url"]["__content__"].gsub("\n", "")
        else
          nil
        end
      {
        source: "goodreads",
        source_id: author["id"],
        name: author["name"],
        image: image
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

  def self.format_book_results(results, current_page)
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
      book_results = results["GoodreadsResponse"]["search"]["results"]["work"]
      books = book_results.kind_of?(Array) ?
              book_results.map { |book_result| format_book(book_result) }.compact :
              [format_book(book_results)] # books should always return array
      {
        total_results: results["GoodreadsResponse"]["search"]["total_results"].to_i,
        current_page: current_page.to_i,
        page_start: results["GoodreadsResponse"]["search"]["results_start"].to_i,
        page_end: results["GoodreadsResponse"]["search"]["results_end"].to_i,
        total_pages: (results["GoodreadsResponse"]["search"]["total_results"].to_f / 19).floor,
        books: books
      }
    end
  end

  def self.format_book(book_result)
    # do not return books without a photo
    return nil if book_result["best_book"]["image_url"].include?("nophoto")
    {
      source_id: book_result["best_book"]["id"],
      source: "goodreads",
      title: book_result["best_book"]["title"],
      authors: [book_result["best_book"]["author"]["name"]],
      published_year: book_result["original_publication_year"],
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
  end
end
