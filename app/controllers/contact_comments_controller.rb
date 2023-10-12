# app/controllers/contact_comments_controller.rb

class ContactCommentsController < ApplicationController
  before_action :authenticate_user! # Add authentication as needed

  def create
    @contact = Contact.find(params[:contact_id])
    @comment = @contact.contact_comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @contact, notice: 'Comment was successfully created.'
    else
      redirect_to @contact, alert: 'Error creating comment.'
    end
  end

  def edit
    @comment = ContactComment.find(params[:id])
    @contact = @comment.contact
  end

  def update
    @comment = ContactComment.find(params[:id])

    if @comment.update(comment_params)
      redirect_to @comment.contact, notice: 'Comment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @comment = ContactComment.find(params[:id])
    @contact = @comment.contact
    @comment.destroy

    redirect_to @contact, notice: 'Comment was successfully deleted.'
  end

  private

  def comment_params
    params.require(:contact_comment).permit(:comment)
  end
end
