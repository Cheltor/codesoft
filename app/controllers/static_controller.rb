class StaticController < ApplicationController
  def dashboard
    @user = current_user
    @recent_comments = @user.comments.order(created_at: :desc).limit(50)
    @recent_violations = @user.violations.where(violations: { status: :current })
    .select {|violation| violation.deadline_date <= Date.tomorrow }
    .reject {|violation| violation.citations.where(citations: { status: [:unpaid, "pending trial"] }).any? {|citation| citation.deadline >= Date.tomorrow }}
    .sort_by(&:deadline_date)

    @recent_citations = @user.citations.where(citations: { status: [:unpaid, "pending trial"] })
    @addresses = @q.result.where.not(streetnumb: nil)
  
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
      @citations = @user.citations.where(citations: { status: [:unpaid, "pending trial"] })
      @comments = @user.comments.order(created_at: :desc).limit(50)
    else
      @violations = Violation.where(violations: { status: :current })
                              .select {|violation| violation.deadline_date <= Date.tomorrow }
                              .reject {|violation| violation.citations.where(citations: { status: [:unpaid, "pending trial"] }).any? {|citation| citation.deadline >= Date.tomorrow }}
                              .sort_by(&:deadline_date)
      @citations = Citation.where(citations: { status: [:unpaid, "pending trial"] })
      @comments = Comment.order(created_at: :desc).limit(50)
    end
  end

  def admin_user
    @users = User.all
  end

  def update_user
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_user_path, notice: "User updated successfully."
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end
end
