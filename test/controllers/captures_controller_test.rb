require 'test_helper'

class CapturesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get captures_index_url
    assert_response :success
  end

  test "should get show" do
    get captures_show_url
    assert_response :success
  end

end
