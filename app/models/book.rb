class Book < ApplicationRecord
  has_many :tags, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :authors
  validates :title, :source, :source_id, :cover_url, presence: true
  before_create :set_title_keywords
  OPENLIBRARY = "openlibrary".freeze
  GOODREADS = "goodreads".freeze
  SOURCES = [GOODREADS, OPENLIBRARY].freeze
  NOT_KEYWORDS = ["AND", "THE", "OR", "OF", "A"].freeze

  def self.by_tags(tags)
    Book.eager_load(:authors, :tags).where("searchable_tags @> array[?]::varchar[]", tags)
  end

  def self.find_or_create(source, source_id)
    raise "Unrecognized source" unless SOURCES.include?(source)
    book = Book.where(source: source, source_id: source_id).first
    return book if book.present?

    case source
    when GOODREADS
      create_goodreads_book(source_id)
    when OPENLIBRARY
      create_openlibrary_book(source_id)
    end
  end

  def self.database_or_external(source, source_id)
    raise "Unrecognized source" unless SOURCES.include?(source)
    book = Book.eager_load(:authors, :comments, :tags).where(source: source, source_id: source_id).first
    return book if book.present?

    case source
    when GOODREADS
      Goodreads.book_details(source_id)
    when OPENLIBRARY
      Openlibrary.book_details(source_id)
    end
  rescue Goodreads::BookNotFound
    raise "Unable to find book with Goodreads id '#{source_id}'"
  rescue Openlibrary::BookNotFound
    raise "Unable to find book with Openlibrary id '#{source_id}'"
  end

  def self.by_query_params(params)
    if params[:title]
      Book.eager_load(:authors).where("ARRAY[:title_keywords]::varchar[] && title_keywords", title_keywords: Book.title_keywords(params[:title]))
    elsif params[:author]
      Book.eager_load(:authors).where("ARRAY[:name_keywords]::varchar[] && authors.name_keywords", name_keywords: Author.name_keywords(params[:author])).references(:authors)
    elsif params[:isbn]
      Book.where(":isbn = ANY(isbns)", isbn: params[:isbn]).eager_load(:authors)
    else
      raise "Unrecognized search type"
    end
  end

  def self.create_goodreads_book(book_id)
    goodreads_book = Goodreads.book_details(book_id)
    goodreads_book[:authors].map! do |author|
      Author.find_or_create_by(name: author[:name]) do |new_author|
        new_author.source = author[:source]
        new_author.source_id = author[:source_id]
        new_author.image = author[:image]
      end
    end
    Book.create(goodreads_book)
  rescue Goodreads::BookNotFound
    raise "Unable to find book with Goodreads id '#{book_id}'"
  end

  def self.create_openlibrary_book(book_id)
    openlibrary_book = Openlibrary.book_details(book_id)
    openlibrary_book[:authors].map! do |author|
      Author.find_or_create_by(name: author[:name]) do |new_author|
        new_author.source = author[:source]
        new_author.source_id = author[:source_id]
        new_author.image = author[:image]
      end
    end
    Book.create(openlibrary_book)
  rescue Openlibrary::BookNotFound
    raise "Unable to find book with Openlibrary id '#{book_id}'"
  end

  def self.title_keywords(title)
    # remove non-word, non-space characters
    title.gsub(/[^\w\s]/, "").upcase.split.map do |word|
      word = word.strip
      if NOT_KEYWORDS.include?(word) || !word.present?
        nil
      else
        word
      end
    end.compact.uniq
  end

  private
    def set_title_keywords
      self.title_keywords = Book.title_keywords(self.title)
    end
end
