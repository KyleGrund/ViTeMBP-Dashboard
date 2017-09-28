class CapturesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?

  def index
    @id = @user.id.to_s
    @captures = Capture.get_captures_for_user(@user.uid)
  end

  def show
    # get upload parameters
    @s3_ul_bucket = Rails.application.secrets.s3_ul_bucket
    @s3_ul_success_base = Rails.application.secrets.s3_ul_success_base
    @s3_ul_access_key = Rails.application.secrets.s3_ul_access_key
    @s3_ul_policy_doc = Rails.application.secrets.s3_ul_policy_doc
    @s3_ul_signature = Rails.application.secrets.s3_ul_signature

    @id = @user.id.to_s
    @capture_id = params[:capture_id]
    @capture = Capture.get_captures_for_user(@user.uid).select { |cap| cap["LOCATION"] == @capture_id }.first

    # if capture not found in users' captures return to root with an error
    redirect_to root_url, :alert => 'Invalid capture location.' if @capture.nil?
  end
end
