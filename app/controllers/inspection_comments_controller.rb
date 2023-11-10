class InspectionCommentsController < ApplicationController
  before_action :authenticate_user! 

  def create
    @inspection = Inspection.find(params[:inspection_id])
    @comment = @inspection.inspection_comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to address_inspection_path(@inspection.address, @inspection), notice: 'Comment was successfully created.'
    else
      redirect_to address_inspection_path(@inspection.address, @inspection), alert: 'Error creating comment.'
    end
  end

  def edit
    @comment = InspectionComment.find(params[:id])
    @inspection = @comment.inspection
  end

  def update
    @comment = InspectionComment.find(params[:id])

    if @comment.update(comment_params)
      redirect_to @comment.inspection, notice: 'Comment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @comment = InspectionComment.find(params[:id])
    @inspection = @comment.inspection
    @comment.destroy

    redirect_to @inspection, notice: 'Comment was successfully deleted.'
  end

  private

  def comment_params
    params.require(:inspection_comment).permit(:content, :inspection_id, :user_id)
  end
end
