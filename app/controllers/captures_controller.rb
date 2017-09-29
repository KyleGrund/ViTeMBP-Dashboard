require 'base64'
require 'openssl'
require 'digest/sha1'

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

    # get upload parameters
    @s3_ul_bucket = Rails.application.secrets.s3_ul_bucket
    @s3_ul_success_base = Rails.application.secrets.s3_ul_success_base
    @s3_ul_access_key = Rails.application.secrets.s3_ul_access_key
    @s3_ul_success_url = @s3_ul_success_base + '/' + @id + '/captures/uploadsuccess/' + @capture['SYSTEM_UUID']
    @s3_ul_policy_doc = build_ul_policy
    @s3_ul_signature = build_ul_policy_signature(@s3_ul_policy_doc)
  end

  def uploadsuccess
    @id = @user.id.to_s
    @capture_id = params[:capture_id]
    @capture = Capture.get_captures_for_user(@user.uid).select { |cap| cap["LOCATION"] == @capture_id }.first
  end

  private

  def build_ul_policy
    # build the time string to expire the policy 12 hours past the current time
    # must provide sufficient time for long uploads of large video files over slower connections
    time = (Time.now.utc + 12*60*60).strftime("%Y-%m-%dT%H:%M:%SZ")

    policy =  '{"expiration": "' + time + '",'
    policy += ' "conditions": ['
    policy += ' {"bucket": "' + @s3_ul_bucket + '"},'
    policy += ' ["starts-with", "$key", "' + @capture['SYSTEM_UUID'] + '/"],'
    policy += ' {"acl": "private"},'
    policy += ' {"success_action_redirect": "' + @s3_ul_success_url + '"},'
    policy += ' ]'
    policy += '}'
    Base64.encode64(policy).gsub("\n", "")
  end

  def build_ul_policy_signature(policy)
    Base64.encode64(
        OpenSSL::HMAC.digest(
            OpenSSL::Digest::Digest.new('sha1'),
            Rails.application.secrets.s3_ul_access_secret, policy)
    ).gsub("\n", "")
  end
end
