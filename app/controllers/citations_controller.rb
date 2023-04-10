class CitationsController < ApplicationController
  def new
    @address = Address.find(params[:address_id])
    @violation = @address.violations.find(params[:violation_id])
    @citation = @violation.citations.new
    @code_ids = @violation.code_ids
  end

  def create
    @address = Address.find(params[:address_id])
    @violation = Violation.find(params[:violation_id])
    @citation = @violation.citations.build(citation_params)
    @citation.user = current_user

    if @citation.save
      redirect_to address_violation_path(@address, @violation), notice: "Citation created successfully"
    else
      render :new
    end
  end

  def my_citations
    @citations = Citation.where(user: current_user)
  end

  def all_citations
    @citations = Citation.all
  end

  private

  def citation_params
    params.require(:citation).permit(:fine, :deadline, code_ids: [])
  end
end
