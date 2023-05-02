class AddressesController < ApplicationController
    def index
        @addresses = @q.result.where.not(streetnumb: nil)
        @violations = Violation.recent
        @comments = Comment.recent
    end
    
    def show
        @address = Address.find(params[:id])
        @address_photos = (
                            @address.violations.map(&:photos) + 
                            @address.comments.map(&:photos)
                          ).flatten.sort_by(&:created_at).reverse
        @address_citations = @address.violations.map(&:citations).flatten
    end

    def violist
        @status = params[:status]
        @violations = Violation.all
      
        case @status
        when "current"
          @violations = @violations.where(status: :current)
        when "resolved"
          @violations = @violations.where(status: :resolved)
        when "closed"
          @violations = @violations.where(status: :closed)
        else
          @status = "all"
        end
      
        @violations = @violations.order(created_at: :desc)
    end

    def my_violations
        @status = params[:status]
        @violations = Violation.where(user: current_user)
      
        case @status
        when "current"
          @violations = @violations.where(status: :current)
        when "resolved"
          @violations = @violations.where(status: :resolved)
        when "closed"
          @violations = @violations.where(status: :closed)
        else
          @status = "all"
        end
      
        @violations = @violations.where(user: current_user).order(created_at: :desc)
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
