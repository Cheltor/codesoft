class AddressesController < ApplicationController
    before_action :authenticate_user!

    def index
        @addresses = @q.result
        @comments = Comment.recent
    end
    
    def show
        @address = Address.find(params[:id])
    end

    def search
        @search = Address.ransack(params[:q])
        @addresses = @search.result
    end
    def edit
     @address = Address.find(params[:id])
    end

    def update
     @address = Address.find(params[:id])
    if @address.update(address_params)
        redirect_to @address, notice: 'Address was successfully updated.'
    else
        render :edit
    end
    end

    def toggle_outstanding_violation
        @address = Address.find(params[:id])
        @address.update(outstanding: !@address.outstanding?)
        redirect_to @address
    end

    private
    def address_params
        params.require(:address).permit(:pid, :ownername, :owneraddress, :ownercity, :ownerstate, :ownerzip, :streetnumb, :streetname, :streettype, :landusecode, :zoning, :owneroccupiedin, :vacant, :absent, :premisezip, :combadd, :outstanding)
    end
end
