require "test_helper"

class CitationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get citations_new_url
    assert_response :success
  end

  test "should get create" do
    get citations_create_url
    assert_response :success
  end
end
