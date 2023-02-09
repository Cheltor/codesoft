require "test_helper"

class ViolationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get violations_new_url
    assert_response :success
  end

  test "should get create" do
    get violations_create_url
    assert_response :success
  end
end
