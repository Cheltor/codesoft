class StaticController < ApplicationController
  def dashboard
    @user = current_user
    @recent_comments = @user.comments.order(created_at: :desc).limit(50)
    @recent_violations = @user.violations.where(violations: { status: :current })
    .select {|violation| violation.deadline_date <= Date.tomorrow }
    .reject {|violation| violation.citations.any? {|citation| citation.deadline >= Date.tomorrow }}
    .sort_by(&:deadline_date)

    @recent_citations = @user.citations.where(citations: { status: [:unpaid, "pending trial"] })
    @addresses = @q.result.where.not(streetnumb: nil)

  end

  def helpful
  end
end
