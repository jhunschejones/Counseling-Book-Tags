require 'httparty'

module Openlibrary
  class BookNotFound < StandardError; end
  class UnrecognizedSearchType < StandardError; end
  BOOKS_PER_PAGE = 1000 # try to return all results in one pass
  OPENLIBRARY = "openlibrary".freeze
  AUTHOR_ROLE = "/type/author_role".freeze

  def self.search_by_title(title, page=1)
    Rails.cache.fetch("source:openlibrary:title:#{title}") do
      response = HTTParty.get("http://openlibrary.org/search.json?title=#{title}&limit=#{BOOKS_PER_PAGE}&page=#{page}", { timeout: 12, format: :json }).parsed_response
      format_book_results(response, page)
    end
  end

  def self.search_by_author(author, page=1)
    Rails.cache.fetch("source:openlibrary:author:#{author}") do
      response = HTTParty.get("http://openlibrary.org/search.json?author=#{author}&limit=#{BOOKS_PER_PAGE}&page=#{page}", { timeout: 12, format: :json }).parsed_response
      format_book_results(response, page)
    end
  end

  def self.search_by_isbn(isbn, page=1)
    Rails.cache.fetch("source:openlibrary:isbn:#{isbn}") do
      response = HTTParty.get("http://openlibrary.org/search.json?isbn=#{isbn}&limit=#{BOOKS_PER_PAGE}&page=#{page}", { timeout: 12, format: :json }).parsed_response
      format_book_results(response, page)
    end
  end

  def self.search_by_query_params(params)
    if params[:title]
      Openlibrary.search_by_title(params[:title], params[:page] || 1)
    elsif params[:author]
      Openlibrary.search_by_author(params[:author], params[:page] || 1)
    elsif params[:isbn]
      Openlibrary.search_by_isbn(params[:isbn], params[:page] || 1)
    else
      raise UnrecognizedSearchType
    end
  end

  def self.book_details(book_id)
    Rails.cache.fetch("source:openlibrary:book_id:#{book_id}") do
      book_response = HTTParty.get("http://openlibrary.org/works/#{book_id}.json", { timeout: 12, format: :json }).parsed_response
      raise BookNotFound if book_response["error"] == "notfound"
      author_responses = book_response["authors"].select { |a| a["type"]["key"] == AUTHOR_ROLE }.map do |author|
        author_id = author["author"]["key"].gsub("/authors/", "")
        HTTParty.get("http://openlibrary.org/authors/#{author_id}.json", { timeout: 12, format: :json }).parsed_response
      end
      book_search = author_responses.length > 0 ? HTTParty.get("http://openlibrary.org/search.json?title=#{Base64.encode64(book_response["title"])}&author=#{Base64.encode64(author_responses[0]["name"])}&limit=1", { timeout: 12, format: :json }).parsed_response["docs"][0] : nil
      {
        source_id: book_id,
        source: OPENLIBRARY,
        title: book_response["title"],
        authors: author_responses.map { |a| format_author(a) },
        isbns: book_search ? book_search["isbn"] : [0],
        published_year: book_search ? (book_search["first_publish_year"] || book_search["publish_date"][0].gsub(/\D/, "")) : nil,
        # publisher: book["publisher"], # too many of these to be practical
        cover_url: "http://covers.openlibrary.org/b/id/#{book_response["covers"][0]}-L.jpg", # there is an array of several covers to choose from here
        description: book_response["description"] ? format_description(book_response["description"]["value"]) : "",
        # language: book["language_code"], # too many of these to be practical
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

  def self.format_book_results(results, page)
    if results["num_found"].to_i == 0
      return { total_results: 0, current_page: 1, page_start: 0, page_end: 0, total_pages: 1, books: [] }
    end
    {
      total_results: results["num_found"].to_i,
      current_page: page.to_i,
      page_start: results["start"].to_i,
      page_end: (results["start"].to_i + BOOKS_PER_PAGE),
      total_pages: (results["num_found"].to_f / BOOKS_PER_PAGE).floor,
      books: results["docs"].map { |result| format_book(result) }.compact,
    }
  end

  def self.format_book(result)
    # Don't return books without covers or authors
    return nil if book_missing_info?(result)
    {
      source_id: result["key"].gsub("/works/", ""),
      source: OPENLIBRARY,
      title: result["title"],
      published_year: result["first_publish_year"],
      cover_url: "http://covers.openlibrary.org/b/id/#{result["cover_i"]}-L.jpg",
      authors: result["author_name"], # array of strings
    }
  end

  def self.book_missing_info?(result)
    !result["cover_i"] ||
    result["cover_i"] == -1 ||
    !result["author_name"] ||
    !result["has_fulltext"]
  end

  def self.format_author(result)
    {
      name: result["name"],
      source: OPENLIBRARY,
      source_id: result["key"].gsub("/authors/", ""),
      image: result["photos"] ? "http://covers.openlibrary.org/b/id/#{result["photos"][0]}-L.jpg" : nil, # there is an array of several images to choose from here
    }
  end

  # Official API
  # http://openlibrary.org/query.json?type=/type/work&title=#{title}&limit=20&*=

  # Experimental API (limit not required, just added for performance, you can then use `&page=2` to go through results)
  # http://openlibrary.org/search.json?title=harry%20potter&limit=20
  # http://openlibrary.org/search.json?title=harry%20potter&limit=20
  # http://openlibrary.org/search.json?author=rowling&limit=20
  # returns a `cover_i` field which can be used to get the cover here: `http://covers.openlibrary.org/b/id/8302846-L.jpg`
  # returns a `key` field which can be used to get book details here: `http://openlibrary.org/works/OL82592W.json` or here: `http://openlibrary.org/query.json?type=/type/work&key=/works/OL82592W&*=`
  # neither of the details pages give author information, you can get an author id from the `authors` array by type, then get more info here `http://openlibrary.org/authors/OL23919A.json`

  # Covers API
  # http://covers.openlibrary.org/b/isbn/9780385533225-L.jpg
end