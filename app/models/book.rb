class Book < ApplicationRecord
  has_many :tags, dependent: :destroy
  validates :title, :authors, :isbn, :published_year, :source, presence: true

  def self.find_or_create(source, source_id)
    raise "Unrecognized source" unless source == "goodreads"

    book = Book.where(source: source, source_id: source_id).first
    return book if book.present?
    Book.create(Goodreads.book_details(source_id))
  rescue Goodreads::BookNotFound
    raise "Unable to find book with Goodreads id '#{source_id}'"
  end

  def self.database_or_external(source, source_id)
    raise "Unrecognized source" unless source == "goodreads"

    book = Book.where(source: source, source_id: source_id).first
    return book if book.present?
    Book.new(Goodreads.book_details(source_id))
  rescue Goodreads::BookNotFound
    raise "Unable to find book with Goodreads id '#{source_id}'"
  end

  def self.search_from_query_params(params)
    if params[:title]
      Book.where("books.title LIKE :query", query: "%#{params[:title]}%")
    elsif params[:author]
      Book.where("books.author LIKE :query", query: "%#{params[:author]}%")
    elsif params[:isbn]
      Book.where("books.isbn LIKE :query", query: "%#{params[:isbn]}%")
    else
      raise "Unrecognized search type"
    end
  end
end
