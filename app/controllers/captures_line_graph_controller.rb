class CapturesLineGraphController < ApplicationController
  def show_all_sensors
    @id = @user.id.to_s
    @capture_id = params[:capture_id]
    @capture = Capture.get_captures_for_user(@user.uid).select { |cap| cap["LOCATION"] == @capture_id }.first

    # if capture not found in users' captures return to root with an error
    redirect_to root_url, :alert => 'Invalid capture location.' if @capture.nil?

    # get capture data
    @capture_details = ServicesControl.send_message_with_response 'CAPTURESUMMARY ' + @capture['LOCATION']
  end
end
