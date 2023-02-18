class StaticController < ApplicationController
  def dashboard
    @user = current_user
    @recent_comments = @user.comments.order(created_at: :desc).limit(50)
    @recent_violations = @user.violations.order(created_at: :desc).limit(50)
  end
end
