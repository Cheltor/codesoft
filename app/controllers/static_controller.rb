class StaticController < ApplicationController
  def home
    @addresses = @q.result
  end
end
