class CommentsController < ApplicationController
    def create
      @address = Address.find(params[:address_id])
      @comment = @address.comments.new(comment_params)
      @comment.user = current_user
      if @comment.save
        redirect_to @address
      else
        render 'addresses/show'
      end
    end
  
    private

    def comment_params
      params.require(:comment).permit(:content, :photo)
    end
  end
  