require 'httparty'

module Openlibrary
  class BookNotFound < StandardError; end
  class UnrecognizedSearchType < StandardError; end

  BookSearchResult = Struct.new(:source_id, :source, :title, :authors, :published_year, :cover_url)
  BookSearchAuthor = Struct.new(:name)

  BOOKS_PER_PAGE = 200
  OPENLIBRARY = "openlibrary".freeze
  AUTHOR_ROLE_TYPE = "/type/author_role".freeze
  PLACEHOLDER_IMAGE_URL = "https://www.abbeville.com/assets/common/images/edition_placeholder.png".freeze
  EXTERNAL_REQUEST_TIMEOUT = 8

  def self.search_by_title(title, page=1, without_covers=false)
    Rails.cache.fetch("source:openlibrary:without_covers:#{without_covers}:title:#{title}") do
      response_json = HTTParty.get("https://openlibrary.org/search.json?title=#{title}&limit=#{BOOKS_PER_PAGE}&page=#{page}", { timeout: EXTERNAL_REQUEST_TIMEOUT, format: :json }).parsed_response
      format_book_results(response_json, page, without_covers)
    end
  end

  def self.search_by_author(author, page=1, without_covers=false)
    Rails.cache.fetch("source:openlibrary:without_covers:#{without_covers}:author:#{author}") do
      response_json = HTTParty.get("https://openlibrary.org/search.json?author=#{author}&limit=#{BOOKS_PER_PAGE}&page=#{page}", { timeout: EXTERNAL_REQUEST_TIMEOUT, format: :json }).parsed_response
      format_book_results(response_json, page, without_covers)
    end
  end

  def self.search_by_isbn(isbn, page=1, without_covers=false)
    Rails.cache.fetch("source:openlibrary:without_covers:#{without_covers}:isbn:#{isbn}") do
      response_json = HTTParty.get("https://openlibrary.org/search.json?isbn=#{isbn}&limit=#{BOOKS_PER_PAGE}&page=#{page}", { timeout: EXTERNAL_REQUEST_TIMEOUT, format: :json }).parsed_response
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
    Rails.cache.fetch("source:openlibrary:book_id:#{book_id}") do
      book_details_response = HTTParty.get("https://openlibrary.org/works/#{book_id}.json", { timeout: EXTERNAL_REQUEST_TIMEOUT, format: :json }).parsed_response
      raise BookNotFound if book_details_response["error"] == "notfound"
      book_details_authors = book_details_response["authors"].select { |a| a["type"] == AUTHOR_ROLE_TYPE || a["type"]["key"] == AUTHOR_ROLE_TYPE }
      author_responses = book_details_authors.map! do |author|
        author_id = author["author"]["key"].gsub("/authors/", "")
        HTTParty.get("https://openlibrary.org/authors/#{author_id}.json", { timeout: EXTERNAL_REQUEST_TIMEOUT, format: :json }).parsed_response
      end
      book_search_response = author_responses.length > 0 ? HTTParty.get("https://openlibrary.org/search.json?title=#{URI.escape(book_details_response["title"])}&author=#{URI.escape(author_responses[0]["name"])}&limit=1", { timeout: EXTERNAL_REQUEST_TIMEOUT, format: :json }).parsed_response["docs"][0] : nil
      {
        source_id: book_id,
        source: OPENLIBRARY,
        title: book_details_response["title"],
        authors: author_responses.map! { |a| format_author(a) },
        isbns: book_search_response ? book_search_response["isbn"] : [0],
        published_year: book_search_response ? (book_search_response["first_publish_year"] || book_search_response["publish_date"][0].gsub(/\D/, "")) : nil,
        publisher: book_details_response["publisher"], # too many of these to be practical
        cover_url: book_details_response["covers"] ? "https://covers.openlibrary.org/b/id/#{book_details_response["covers"][0]}-L.jpg" : PLACEHOLDER_IMAGE_URL, # there is an array of several covers to choose from here
        description: book_details_response["description"] ? format_description(book_details_response["description"]["value"]) : "",
        language: book_details_response["language_code"], # too many of these to be practical
      }
    end
  end

  def self.format_description(raw_description)
    return "" unless raw_description
    raw_description
      .gsub(/\/?\\r\\n/, " <br /><br /> ") # replace custom line breaks with expected format
      .gsub(/\[\d\]:?/, "") # replace digits in brackets
      .gsub(/https:\/\/\S*|\/\b/, "") # replace urls
      .gsub("([source])", "")
      .split(/-{3,}/)[0] # remove end section divided by 3+ dashes
  end

  def self.format_book_results(results, page, without_covers)
    if results["num_found"].to_i == 0
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
        total_results: results["num_found"].to_i,
        current_page: page.to_i,
        page_start: results["start"].to_i,
        page_end: (results["start"].to_i + BOOKS_PER_PAGE),
        total_pages: (results["num_found"].to_f / BOOKS_PER_PAGE).floor,
        books: results["docs"].map! { |result| format_book(result, without_covers) }.compact,
      }
    end
  end

  def self.format_book(result, without_covers)
    # Don't return books without covers or authors
    return nil if book_missing_info?(result, without_covers)
    BookSearchResult.new(
      result["key"].gsub("/works/", ""),
      OPENLIBRARY,
      result["title"],
      result["author_name"].map { |name| BookSearchAuthor.new(name) }, # convert array of strings to array of objects that respond to `.name`
      result["first_publish_year"],
      result["cover_i"] ? "https://covers.openlibrary.org/b/id/#{result["cover_i"]}-L.jpg" : PLACEHOLDER_IMAGE_URL,
    )
  end

  def self.book_missing_info?(result, without_covers)
    if !without_covers
      #
      # To clean up results further in the future, try filtering out books
      # missing the following values:
      #
      # result["id_amazon"]
      # result["has_fulltext"]
      #
      !result["cover_i"] ||
      result["cover_i"] == -1 ||
      !result["author_name"]
    else
      !result["author_name"]
    end
  end

  def self.format_author(result)
    {
      name: result["name"],
      source: OPENLIBRARY,
      source_id: result["key"].gsub("/authors/", ""),
      image: result["photos"] ? "https://covers.openlibrary.org/b/id/#{result["photos"][0]}-L.jpg" : nil, # there is an array of several images to choose from here
    }
  end

  private_class_method :format_description, :format_book_results, :format_book, :book_missing_info?, :format_author

  # Official API
  # https://openlibrary.org/query.json?type=/type/work&title=#{title}&limit=20&*=

  # Experimental API (limit not required, just added for performance, you can then use `&page=2` to go through results)
  # https://openlibrary.org/search.json?title=harry%20potter&limit=20
  # https://openlibrary.org/search.json?title=harry%20potter&limit=20
  # https://openlibrary.org/search.json?author=rowling&limit=20
  # returns a `cover_i` field which can be used to get the cover here: `https://covers.openlibrary.org/b/id/8302846-L.jpg`
  # returns a `key` field which can be used to get book details here: `https://openlibrary.org/works/OL82563W.json` or here: `https://openlibrary.org/query.json?type=/type/work&key=/works/OL82563W&*=`
  # neither of the details pages give author information, you can get an author id from the `authors` array by type, then get more info here `https://openlibrary.org/authors/OL23919A.json`

  # Covers API
  # https://covers.openlibrary.org/b/isbn/9780385533225-L.jpg
end
