class ViolationCommentsController < ApplicationController
  before_action :authenticate_user! 

  def create
    @violation = Violation.find(params[:violation_id])
    @comment = @violation.violation_comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @violation, notice: 'Comment was successfully created.'
    else
      redirect_to @violation, alert: 'Error creating comment.'
    end
  end

  def edit
    @comment = ViolationComment.find(params[:id])
    @violation = @comment.violation
  end

  def update
    @comment = ViolationComment.find(params[:id])

    if @comment.update(comment_params)
      redirect_to @comment.violation, notice: 'Comment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @comment = ViolationComment.find(params[:id])
    @violation = @comment.violation
    @comment.destroy

    redirect_to @violation, notice: 'Comment was successfully deleted.'
  end

  private

  def comment_params
    params.require(:violation_comment).permit(:content, :violation_id, :user_id)
  end
end
