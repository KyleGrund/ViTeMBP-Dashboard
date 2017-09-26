class CapturesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?

  def index
    @id = @user.id.to_s
    @captures = Capture.get_captures_for_user(@user.uid)
  end

  def show
    @id = @user.id.to_s
    @capture_id = params[:capture_id]
    @capture = Capture.get_captures_for_user(@user.uid).select { |cap| cap["LOCATION"] == @capture_id }.first

    # if capture not found in users' captures return to root with an error
    redirect_to root_url, :alert => 'Invalid capture location.' if @capture.nil?
  end
end
