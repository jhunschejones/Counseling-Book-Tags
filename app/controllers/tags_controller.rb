class TagsController < ApplicationController
  skip_before_action :authenticate_user, only: [:index]

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
