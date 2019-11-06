class TagsController < ApplicationController
  skip_before_action :authenticate_user, only: [:index, :destroy]

  def index
  end

  def create
    book = Book.find_or_create(book_params["source"], book_params["source_id"])
    tags = tag_params["text"].split(",").map do |tag|
      Tag.create(text: tag.strip, book_id: book.id, user_id: @user.id)
    end

    render json: { data: tags.map { |tag| {id: tag.id, type: "tag", attributes: {text: tag.text}} } }
  rescue ActiveRecord::RecordNotUnique
    render json: { errors: [{ status: 500, title: "Duplicate record", detail: "The '#{tag_params["text"]}' tag already exists " }] }
  end

  def destroy
    head Tag.delete(params["id"].to_i) ? :no_content : :internal_server_error
  end

  private
  def tag_params
    params.require(:tag).permit(:text, :id)
  end

  def book_params
    params.require(:book).permit(:source, :source_id)
  end
end
