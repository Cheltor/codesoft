class PromptsController < ApplicationController
    before_action :authenticate_user!

    def new
        @room = Room.find(params[:room_id])
        @prompt = @room.prompts.build
    end

    def create
        @room = Room.find(params[:room_id])
        @prompt = @room.prompts.build(prompt_params)
        if @prompt.save
            redirect_to @room, notice: "Prompt created!"
        else
            render :new
        end
    end

    def edit
        @room = Room.find(params[:room_id])
        @prompt = @room.prompts.find(params[:id])
    end

    def update
        @room = Room.find(params[:room_id])
        @prompt = @room.prompts.find(params[:id])
        if @prompt.update(prompt_params)
            redirect_to @room, notice: "Prompt updated!"
        else
            render :edit
        end
    end

    def destroy
        @room = Room.find(params[:room_id])
        @prompt = @room.prompts.find(params[:id])
        @prompt.destroy
        redirect_to @room, notice: "Prompt deleted!"
    end

    private

    def prompt_params
        params.require(:prompt).permit(:content)
    end
end
