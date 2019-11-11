class TagsController < ApplicationController
  skip_before_action :authenticate_user, only: [:destroy]

  def index
    @tags = Tag.order(:text).uniq { |tag| tag.text }
  end

  def create
    book = Book.find_or_create(book_params["source"], book_params["source_id"])
    tags = tag_params["text"].split(",").map do |tag|
      Tag.create(text: tag.strip, book_id: book.id, user_id: @user.id)
    end
    Thread.new do
      sleep 1
      book.searchable_tags = book.tags.map { |tag| tag.text }.uniq
      book.save!
      ActiveRecord::Base.connection.close
    end

    render json: { data: tags.map { |tag| {id: tag.id, type: "tag", attributes: {text: tag.text}} } }
  rescue ActiveRecord::RecordNotUnique
    render json: { errors: [{ status: 500, title: "Duplicate record", detail: "The '#{tag_params["text"]}' tag already exists " }] }
  end

  def destroy
    tag = Tag.eager_load(:book).find(params["id"].to_i)
    book = tag.book
    Thread.new do
      sleep 1
      book.searchable_tags = book.tags.map { |tag| tag.text }.uniq
      book.save!
      ActiveRecord::Base.connection.close
    end

    # JSON API content deleted response
    head tag.destroy ? :no_content : :internal_server_error
  end

  private
  def tag_params
    params.require(:tag).permit(:text, :id)
  end

  def book_params
    params.require(:book).permit(:source, :source_id)
  end
end
