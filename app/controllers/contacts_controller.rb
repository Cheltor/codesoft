class ContactsController < ApplicationController
  before_action :authenticate_user!
  def index
    @contact_q = Contact.ransack(params[:q])
    @contacts = @contact_q.result(distinct: true).where(hidden: false).order(created_at: :desc)
    @contacts = @contacts.paginate(page: params[:page], per_page: 15)
  end

  def new
    @contact = Contact.new
  end

  def create
    Contact.create(contact_params)
    redirect_to contacts_path
  end

  def show
    @contact = Contact.find(params[:id])
    @businesses = @contact.businesses.paginate(page: params[:business_page], per_page: 5)
    @addresses = @contact.addresses.paginate(page: params[:address_page], per_page: 5)
    @units = @contact.units.paginate(page: params[:unit_page], per_page: 5)
    @contact_comments = @contact.contact_comments.order(created_at: :desc).paginate(page: params[:comment_page], per_page: 5)
    @inspections = @contact.inspections.order(created_at: :desc).paginate(page: params[:inspection_page], per_page: 5)
  end
  

  def edit
    @contact = Contact.find(params[:id])
  end

  def update
    Contact.find(params[:id]).update(contact_params)
    redirect_to contacts_path
  end

  def destroy
    Contact.find(params[:id]).destroy
    redirect_to contacts_path
  end

  def add_notes
    @contact = Contact.find(params[:id])
  end

  def hide
    @contact = Contact.find(params[:id])
    @contact.update(hidden: true)
    redirect_to contacts_path, notice: 'Contact was successfully deleted.'
  end
  
  private

  def contact_params
    params.require(:contact).permit(:name, :email, :phone, :notes)
  end
end