require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get static_home_url
    assert_response :success
  end

  test "should get dashboard" do
    get dashboard_url
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:comments)
    assert_not_nil assigns(:comments_last_week)
    assert_not_nil assigns(:comments_two_weeks_ago)
    assert_not_nil assigns(:active_violations)
    assert_not_nil assigns(:violations)
    assert_not_nil assigns(:citations)
    assert_not_nil assigns(:addresses)
    assert_not_nil assigns(:inspections)
    assert_not_nil assigns(:today_inspections)
    assert_not_nil assigns(:future_inspections)
    assert_not_nil assigns(:past_inspections)
    assert_not_nil assigns(:complaints)
    assert_not_nil assigns(:unscheduled_inspections)
    assert_not_nil assigns(:priority_addresses)
    assert_not_nil assigns(:timeline_items)
    assert_template :dashboard
  end
end