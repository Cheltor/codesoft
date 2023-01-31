class AddressController < ApplicationController
    def show
        @address = Address.find(params[:id])
    end
end
