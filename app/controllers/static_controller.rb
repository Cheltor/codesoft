class StaticController < ApplicationController
  skip_before_action :authenticate_user!, only: [:issue, :dashboard, :helpful]

  def dashboard
    @user = current_user
    @comments = @user.comments.order(created_at: :desc).limit(50)
    @violations = @user.violations.where(violations: { status: :current })
                              .select {|violation| violation.deadline_date <= Date.tomorrow }
                              .reject {|violation| violation.citations.where(citations: { status: [:unpaid, "pending trial"] }).all? {|citation| citation.deadline >= Date.tomorrow }}
                              #.where.not(id: Citation.where(status: "pending trial", violation: @user.violations).pluck(:violation_id))
                              .sort_by(&:deadline_date)

    @citations = @user.citations.where(citations: { status: [:unpaid, "pending trial"] }).sort_by(&:deadline)
    @addresses = @q.result.where.not(streetnumb: nil)
  
  end

  def issue
    @addresses = @q.result.where.not(streetnumb: nil)
    @concern = Concern.new # Create a new concern object for the form
  end

  def helpful
  end

  def admin
    @addresses = @q.result.where.not(streetnumb: nil)

    @ons_users = User.where(role: :ons)


    if params[:onsstaff].present?
      @user = User.find_by(email: params[:onsstaff])
      @violations = @user.violations.where(violations: { status: :current })
                          .select {|violation| violation.deadline_date <= Date.tomorrow }
                          .reject {|violation| violation.citations.where(citations: { status: [:unpaid, "pending trial"] }).any? {|citation| citation.deadline >= Date.tomorrow }}
                          .sort_by(&:deadline_date)
      @citations = @user.citations.where(citations: { status: [:unpaid, "pending trial"] }).sort_by(&:deadline)
      @comments = @user.comments.order(created_at: :desc).limit(50)
      @inspections = Inspection.where(assignee: @user).order(created_at: :desc).limit(50)
    else
      @violations = Violation.where(violations: { status: :current })
                              .select {|violation| violation.deadline_date <= Date.tomorrow }
                              .reject {|violation| violation.citations.where(citations: { status: [:unpaid, "pending trial"] }).any? {|citation| citation.deadline >= Date.tomorrow }}
                              .sort_by(&:deadline_date)
      @citations = Citation.where(citations: { status: [:unpaid, "pending trial"] }).sort_by(&:deadline)
      @comments = Comment.order(created_at: :desc).limit(50)
      @inspections = Inspection.order(created_at: :desc).limit(50)
    end
  end

  def admin_user
    unless current_user.admin?
      redirect_to root_path, notice: "You are not authorized to access this page."
    end

    @users = User.all
  end

  def update_user
    unless current_user.admin?
      redirect_to root_path, notice: "You are not authorized to access this page."
    end
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_user_path, notice: "User updated successfully."
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :role, :phone)
  end
end
