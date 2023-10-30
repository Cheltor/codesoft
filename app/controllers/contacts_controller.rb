# Contacts controller

class ContactsController < ApplicationController
  def index
    @contact_q = Contact.ransack(params[:q])
    @contacts = @contact_q.result(distinct: true).where(hidden: false).order(created_at: :desc)
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
    @businesses = @contact.businesses
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