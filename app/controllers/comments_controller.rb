class CommentsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    # Determine the parent object for the comment
    parent = Address.find_by(id: params[:address_id]) || Unit.find_by(id: params[:unit_id])
  
    # Handle the case where neither an Address nor a Unit is found
    unless parent
      # Redirect to a suitable error page or show an error message
      redirect_to some_error_path, alert: "Parent object not found"
      return
    end
  
    @comment = parent.comments.new(comment_params)
    @comment.user = current_user
  
    if @comment.save
      # Redirect based on the type of the parent object
      redirect_path = parent.is_a?(Address) ? address_path(parent) : unit_path(parent)
      redirect_to "#{redirect_path}#activities", notice: 'Comment was successfully created.'
    else
      render "#{parent.class.name.downcase}s/show"
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
      params.require(:comment).permit(:content, :unit_id, photos: [])
    end
  end
  