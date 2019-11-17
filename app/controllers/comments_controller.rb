class CommentsController < ApplicationController
  def create
    book = Book.find_or_create(book_params["source"], book_params["source_id"])
    comment = Comment.create(body: comment_params["body"], book_id: book.id, user_id: @user.id)
    render json: comment.success_response
  end

  def update
    comment = Comment.where(id: params["id"].to_i, user_id: @user.id).first
    if comment.present? && comment.update(body: comment_params[:body])
      render json: comment.success_response
    else
      head :internal_server_error
    end
  end

  def destroy
    comment = Comment.where(id: params["id"].to_i, user_id: @user.id).first
    # JSON API content deleted response
    head comment && comment.destroy ? :no_content : :internal_server_error
  end

  private
    def comment_params
      params.require(:comment).permit(:body, :book_id)
    end

    def book_params
      params.require(:book).permit(:source, :source_id)
    end
end
