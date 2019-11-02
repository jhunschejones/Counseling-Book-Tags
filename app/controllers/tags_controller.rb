class TagsController < ApplicationController
  def index
  end

  def create
  end

  def destroy
  end

  private
  def tag_params
    params.require(:tag).permit(:text, :book_id, :user_id)
  end
end
