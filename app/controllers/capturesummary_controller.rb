class CapturesummaryController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?

  def get_summary
    @id = @user.id.to_s
    @capture_id = params[:capture_id]
    @capture = Capture.get_captures_for_user(@user.uid).select { |cap| cap["LOCATION"] == @capture_id }.first

    # if capture not found in users' captures return to root with an error
    redirect_to root_url, :alert => 'Invalid capture location.' if @capture.nil?

    # get capture summary
    capture_summary = ServicesControl.send_message_with_response 'CAPTURESUMMARY ' + @capture['LOCATION'] || '[]'

    # just return the data from the response instead of rendering a view
    respond_to do |format|
      format.html { render :plain => capture_summary }
    end
  end
end
