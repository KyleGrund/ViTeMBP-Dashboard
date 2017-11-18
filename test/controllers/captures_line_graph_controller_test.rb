require 'test_helper'

class CapturesLineGraphControllerTest < ActionDispatch::IntegrationTest
  test "should get show_all_sensors" do
    get captures_line_graph_show_all_sensors_url
    assert_response :success
  end

end
