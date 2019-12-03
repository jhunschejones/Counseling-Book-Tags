require 'httparty'

module Goodreads
  class BookNotFound < StandardError; end
  class UnrecognizedSearchType < StandardError; end

  BookSearchResult = Struct.new(:source_id, :source, :title, :authors, :published_year, :cover_url)
  BookSearchAuthor = Struct.new(:name)

  PLACEHOLDER_IMAGE_URL = "https://www.abbeville.com/assets/common/images/edition_placeholder.png".freeze
  EXTERNAL_REQUEST_TIMEOUT = 8
  RESULTS_PER_PAGE = 19 # set in goodreads API, cannot be changed by client

  def self.search_by_title(title, page=1, without_covers=false)
    Rails.cache.fetch("source:goodreads:without_covers:#{without_covers}:title:#{title}:page:#{page}") do
      response_json = HTTParty.get("https://www.goodreads.com/search/index.xml?key=#{ENV["GOODREADS_KEY"]}&q=#{title}&search[field]=title&page=#{page}", timeout: EXTERNAL_REQUEST_TIMEOUT).parsed_response
      format_book_results(response_json, page, without_covers)
    end
  end

  def self.search_by_author(author, page=1, without_covers=false)
    Rails.cache.fetch("source:goodreads:without_covers:#{without_covers}:author:#{author}:page:#{page}") do
      response_json = HTTParty.get("https://www.goodreads.com/search/index.xml?key=#{ENV["GOODREADS_KEY"]}&q=#{author}&search[field]=author&page=#{page}", timeout: EXTERNAL_REQUEST_TIMEOUT).parsed_response
      format_book_results(response_json, page, without_covers)
    end
  end

  # Goodreads API appears to only work with ISBN13?
  def self.search_by_isbn(isbn, page=1, without_covers=false)
    Rails.cache.fetch("source:goodreads:without_covers:#{without_covers}:isbn:#{isbn}:page:#{page}") do
      response_json = HTTParty.get("https://www.goodreads.com/search/index.xml?key=#{ENV["GOODREADS_KEY"]}&q=#{isbn}&search[field]=isbn&page=#{page}", timeout: EXTERNAL_REQUEST_TIMEOUT).parsed_response
      format_book_results(response_json, page, without_covers)
    end
  end

  def self.search_by_query_params(params)
    page = params[:page] || 1
    without_covers = params[:without_covers] || false

    if params[:title]
      search_by_title(params[:title], page, without_covers)
    elsif params[:author]
      search_by_author(params[:author], page, without_covers)
    elsif params[:isbn]
      search_by_isbn(params[:isbn], page, without_covers)
    else
      raise UnrecognizedSearchType
    end
  end

  def self.book_details(book_id)
    Rails.cache.fetch("source:goodreads:book_id:#{book_id}") do
      response = HTTParty.get("https://www.goodreads.com/book/show.xml?key=#{ENV["GOODREADS_KEY"]}&id=#{book_id}", timeout: EXTERNAL_REQUEST_TIMEOUT).parsed_response
      raise BookNotFound if response["error"] == "Page not found"
      book = response["GoodreadsResponse"]["book"]
      authors =
        if book["authors"]["author"].kind_of?(Array)
          book["authors"]["author"].map! { |author| format_author(author) }.compact
        else
          [format_author(book["authors"]["author"])] # `authors` should always be an array
        end

      {
        source_id: book["id"],
        source: "goodreads",
        title: book["title"],
        authors: authors,
        isbns: [book["isbn"], book["isbn13"]],
        published_year: book["publication_year"],
        publisher: book["publisher"],
        cover_url: cover_or_placeholder(book["image_url"]),
        description: format_description(book["description"]),
        language: book["language_code"],
      }
    end
  end

  def self.format_author(author)
    if !author["role"] # only return authors, not other roles like illustrator
      image = author["image_url"]["nophoto"] == "false" ?
              author["image_url"]["__content__"].gsub("\n", "") : nil
      {
        source: "goodreads",
        source_id: author["id"],
        name: author["name"],
        image: image
      }
    end
  end

  def self.format_description(description)
    return "" unless description
    description
      .gsub(/(<br \/>){1,3}/, "<br /><br />") # only include break tags in sets of 2
      .gsub(/<i>|<\/i>/, "\"") # use quotes instead of <i> tags
      .gsub("--back cover", "") # remove source citation
      .split("Source: <")[0] # remove source citation
      .gsub(/--\w*.com$/, "") # remove source citation
  end

  def self.format_book_results(results, current_page, without_covers)
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
              book_results.map! { |book_result| format_book(book_result, without_covers) }.compact :
              [format_book(book_results, without_covers)] # books should always be an array
      {
        total_results: results["GoodreadsResponse"]["search"]["total_results"].to_i,
        current_page: current_page.to_i,
        page_start: results["GoodreadsResponse"]["search"]["results_start"].to_i,
        page_end: results["GoodreadsResponse"]["search"]["results_end"].to_i,
        total_pages: (results["GoodreadsResponse"]["search"]["total_results"].to_f / RESULTS_PER_PAGE).floor,
        books: books
      }
    end
  end

  def self.format_book(book_result, without_covers)
    # do not return books without a photo
    return nil if book_result["best_book"]["image_url"].include?("nophoto") && !without_covers
    BookSearchResult.new(
      book_result["best_book"]["id"],
      "goodreads",
      book_result["best_book"]["title"],
      [BookSearchAuthor.new(book_result["best_book"]["author"]["name"])],
      book_result["original_publication_year"],
      cover_or_placeholder(book_result["best_book"]["image_url"])
    )
  end

  def self.cover_or_placeholder(cover_url)
    return PLACEHOLDER_IMAGE_URL if cover_url.include?("nophoto")
    #
    # "image_url" field ends like `3._SX98_.jpg`. This string can be adjusted to
    # return different size images. Values and their meanings are as follows:
    #
    # - `SX` is size on the x-axis
    # - `SY` is size on the y-axis
    # - `98` is the size in pixels
    #
    cover_url.gsub(/_\w{2}\d{1,3}_/, "_SX250_")
  end

  private_class_method :format_author, :format_description, :format_book_results, :format_book, :cover_or_placeholder
end
