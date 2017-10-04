class Capture < ApplicationRecord
  require 'aws-sdk'

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
        user.name = auth['info']['name'] || ""
      end
    end
  end

  def self.get_videos_for_capture(capture_id)
    s3 = Aws::S3::Client.new
    vid_objs = s3.list_objects_v2(
        bucket: Rails.application.secrets.s3_output_bucket,
        prefix: capture_id + '/')
    vid_objs['contents'].select { |elm| elm['size'].positive? }.map { |elm| { :name => elm['key'], :last_modified => elm['last_modified'] } }
  end

  def self.get_capture_for_id(capture_id)
    # gets row in the captures table which match the capture uuid
    dynamodb = Aws::DynamoDB::Client.new
    dynamodb.get_item({
         table_name: 'CAPTURES',
         filter_expression: 'LOCATION = :LOCATION',
         expression_attribute_values: {
             ':LOCATION' => capture_id.to_s
         }
     }).item
  end

  def self.get_captures_for_system(system_uuid)
    # gets all rows in the captures table which match the system's uuid
    dynamodb = Aws::DynamoDB::Client.new
    rows = dynamodb.scan({
         table_name: 'CAPTURES',
         filter_expression: 'SYSTEM_UUID = :SYSTEM_UUID',
         expression_attribute_values: {
             ':SYSTEM_UUID' => system_uuid.to_s
         }
     }).items || []

    # return just the device ids, not the rest of the data in the row
    devices = Array.new()
    rows.each { |cap| devices.push(cap) }
    devices
  end

  def self.get_captures_for_user(uuid)
    captures = Array.new()
    Device.get_devices(uuid).each {|dev| get_captures_for_system(dev).each {|cap| captures.push cap}}
    captures
  end
end
