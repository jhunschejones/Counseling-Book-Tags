class Book < ApplicationRecord
  has_many :tags, dependent: :destroy
  has_and_belongs_to_many :authors
  validates :title, :isbn, :published_year, :source, presence: true

  # Find books that match ALL searched tags and return those records
  # along with all their associated tags
  def self.by_tags(tags)
    # query_array = tags.map {|tag| "%#{tag}%" }
    # Book.find_by_sql(["SELECT DISTINCT books.* FROM books
    #                   INNER JOIN tags ON books.id = tags.book_id
    #                   WHERE (tags.text ILIKE ALL ( array[?] ))", query_array])
    Book.find_by_sql(["SELECT DISTINCT books.* FROM books
                      INNER JOIN tags ON books.id = tags.book_id
                      WHERE books.searchable_tags @> array[?]", tags])
  end

  def self.find_or_create(source, source_id)
    raise "Unrecognized source" unless source == "goodreads"
    book = Book.where(source: source, source_id: source_id).first
    return book if book.present?
    goodreads_book = Goodreads.book_details(source_id)
    goodreads_book[:authors].map! do |author|
      Author.find_or_create_by(name: author[:name]) do |new_author|
        new_author.source = author[:source]
        new_author.source_id = author[:source_id]
        new_author.image = author[:image]
      end
    end
    Book.create(goodreads_book)
  rescue Goodreads::BookNotFound
    raise "Unable to find book with Goodreads id '#{source_id}'"
  end

  def self.database_or_external(source, source_id)
    raise "Unrecognized source" unless source == "goodreads"
    book = Book.eager_load(:tags, :authors).where(source: source, source_id: source_id).first
    return book if book.present?
    Goodreads.book_details(source_id)
  rescue Goodreads::BookNotFound
    raise "Unable to find book with Goodreads id '#{source_id}'"
  end

  def self.by_query_params(params)
    if params[:title]
      Book.where("lower(title) LIKE :query", query: "%#{params[:title].downcase}%")
    elsif params[:author]
      Book.includes(:authors).where("lower(authors.name) LIKE :query", query: "%#{params[:author].downcase}%").references(:authors)
    elsif params[:isbn]
      Book.where(isbn: params[:isbn].to_i)
    else
      raise "Unrecognized search type"
    end
  end
end
