require 'test_helper'

class DevicesControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get devices_list_url
    assert_response :success
  end

  test "should get register" do
    get devices_register_url
    assert_response :success
  end

end
