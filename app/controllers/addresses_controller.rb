class AddressesController < ApplicationController
    before_action :authenticate_user!

    def index
        @addresses = @q.result
        @violations = Violation.recent
    end

    def violist
        @violations =Violation.where(violations: { status: :current }).order("updated_at DESC").distinct
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

    private
    def address_params
        params.require(:address).permit(:pid, :ownername, :owneraddress, :ownercity, :ownerstate, :ownerzip, :streetnumb, :streetname, :streettype, :landusecode, :zoning, :owneroccupiedin, :vacant, :absent, :premisezip, :combadd, :outstanding)
    end
end
