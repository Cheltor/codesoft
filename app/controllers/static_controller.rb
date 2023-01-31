class StaticController < ApplicationController
  def home
    @addresses = Address.all
  end
end
