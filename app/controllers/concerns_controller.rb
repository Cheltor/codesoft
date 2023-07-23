class ConcernsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]
  def create
    @address = Address.find(params[:address_id])
    @concern = @address.concerns.build(concern_params)

    if @concern.save
      redirect_to root_path, notice: "Concern successfully submitted."
    else
      # Handle errors if needed
    end
  end

  private

  def concern_params
    params.require(:concern).permit(:content)
  end
end
