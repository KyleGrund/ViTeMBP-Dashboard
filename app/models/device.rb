class Device < ApplicationRecord
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

  def self.get_devices(uuid)
    dynamodb = Aws::DynamoDB::Client.new
    dynamodb.scan({
        table_name: 'DEVICES',
        filter_expression: 'CUSTOMER_UUID = :CUSTOMER_UUID',
        expression_attribute_values: {
            ':CUSTOMER_UUID' => uuid.to_s
        }
      }).items || []
  end

  def self.get_user_registered_to(serial)
    dynamodb = Aws::DynamoDB::Client.new
    # if the serial has been claimed it will be in the DEVICES table
    binding = dynamodb.get_item(
        table_name: 'DEVICES',
        key: {
            'ID' => serial
        }
    ).item

    unless binding.nil?
      return binding['CUSTOMER_UUID']
    end

    nil
  end

  def self.is_device_registered(serial)
    dynamodb = Aws::DynamoDB::Client.new
    # if the serial is registered in the db it will be in the DEVICES table
    !dynamodb.get_item(
        table_name: 'DEVICES',
        key: {
            'ID' => serial
        }
    ).item.nil?
  end

  def self.register_device(serial, uid)
    begin
      # update the device entry with the current user's uuid so long as
      # there isn't already another value bound to it.
      dynamodb = Aws::DynamoDB::Client.new
      dynamodb.update_item({
        table_name: 'DEVICES',
        key: {
              'ID' => serial.to_s,
        },
        condition_expression: 'attribute_exists(ID) AND attribute_not_exists(CUSTOMER_UUID)',
        update_expression: "SET CUSTOMER_UUID = :customer_uuid",
        expression_attribute_values: {
            ':customer_uuid' => uid.to_s
        }
      })
    rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
      return false
    end
    true
  end
end
