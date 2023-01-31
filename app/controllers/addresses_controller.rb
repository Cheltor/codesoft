class AddressesController < ApplicationController
    def index
        @addresses = @q.result
    end
    
    def show
        @address = Address.find(params[:id])
    end

    def search
        @search = Address.ransack(params[:q])
        @addresses = @search.result
    end
end
