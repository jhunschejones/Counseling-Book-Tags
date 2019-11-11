class CommentsController < ApplicationController
  def create
    book = Book.find_or_create(book_params["source"], book_params["source_id"])
    comment = Comment.create(body: comment_params["body"].strip, book_id: book.id, user_id: @user.id)
    render json: comment.successfully_created_response
  end

  def update
    comment = Comment.find(params["id"].to_i)
    head comment.update(body: comment_params[:body]) ? :ok : :internal_server_error
  end

  def destroy
    comment = Comment.find(params["id"].to_i)
    # JSON API content deleted response
    head comment.destroy ? :no_content : :internal_server_error
  end

  private
    def comment_params
      params.require(:comment).permit(:body, :book_id)
    end

    def book_params
      params.require(:book).permit(:source, :source_id)
    end
end
