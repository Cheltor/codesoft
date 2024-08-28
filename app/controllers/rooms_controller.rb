class RoomsController < ApplicationController
    def index
        @rooms = Room.all
    end

    def show
        @room = Room.find(params[:id])
        @prompts = @room.prompts
    end

    def new
        @room = Room.new
    end

    def create
        @room = Room.new(room_params)
        if @room.save
            redirect_to @room, notice: "Room created!"
        else
            render :new
        end
    end

    def edit
        @room = Room.find(params[:id])
    end

    def update
        @room = Room.find(params[:id])
        if @room.update(room_params)
            redirect_to @room, notice: "Room updated!"
        else
            render :edit
        end
    end

    def destroy
        @room = Room.find(params[:id])
        @room.destroy
        redirect_to rooms_path, notice: "Room deleted!"
    end

    private

    def room_params
        params.require(:room).permit(:name)
    end
end
