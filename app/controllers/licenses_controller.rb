class LicensesController < ApplicationController
  def index
    @licenses = License.all
  end

  def show
    @license = License.find(params[:id])
  end

  def new
    @license = License.new
  end

  def create
    # Your code here
  end

  def edit
    # Your code here
  end

  def update
    # Your code here
  end

  def destroy
    # Your code here
  end

  def email_license
    # Your code here
  end

  def download_license
    # Your code here
  end
end
