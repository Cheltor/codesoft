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

    def edit
      @address = Address.find(params[:address_id])
      @comment = @address.comments.find(params[:id])
    end
  
    def update
      @address = Address.find(params[:address_id])
      @comment = @address.comments.find(params[:id])
      
      if @comment.update(comment_params)
        redirect_to @address, notice: 'Comment was successfully updated.'
      else
        render :edit
      end
    end
  
    private

    def comment_params
      params.require(:comment).permit(:content, photos: [])
    end
  end
  