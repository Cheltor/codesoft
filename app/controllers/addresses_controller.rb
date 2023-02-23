class AddressesController < ApplicationController
    def index
        @addresses = @q.result.where.not(streetnumb: nil)
        @violations = Violation.recent
        @comments = Comment.recent
    end

    def violist
        @violations =Violation.where(violations: { status: :current }).sort_by(&:deadline_date)
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
