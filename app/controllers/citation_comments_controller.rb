class CitationCommentsController < ApplicationController
  before_action :authenticate_user! 

  def create
    @citation = Citation.find(params[:citation_id])
    @comment = @citation.citation_comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @citation, notice: 'Comment was successfully created.'
    else
      redirect_to @citation, alert: 'Error creating comment.'
    end
  end

  def edit
    @comment = CitationComment.find(params[:id])
    @citation = @comment.citation
  end

  def update
    @comment = CitationComment.find(params[:id])

    if @comment.update(comment_params)
      redirect_to @comment.citation, notice: 'Comment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @comment = CitationComment.find(params[:id])
    @citation = @comment.citation
    @comment.destroy

    redirect_to @citation, notice: 'Comment was successfully deleted.'
  end

  private

  def comment_params
    params.require(:citation_comment).permit(:content, :citation_id, :user_id, photos: [])
  end
end
