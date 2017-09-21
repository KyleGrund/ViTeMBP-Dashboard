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
    dynamodb.query({
        table_name: 'DEVICE_TO_CUSTOMER',
        key_condition_expression: 'CUSTOMER_UUID = :CUSTOMER_UUID',
        expression_attribute_values: {
            ':CUSTOMER_UUID' => uuid.to_s
        }
      }).items || []
  end

  def self.get_user_registered_to(serial)
    dynamodb = Aws::DynamoDB::Client.new
    # if the serial has been claimed it will be in the DEVICE_TO_CUSTOMER table
    binding = dynamodb.get_item(
        table_name: 'DEVICE_TO_CUSTOMER',
        key: {
            'DEVICE_UUID' => serial
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
      dynamodb = Aws::DynamoDB::Client.new
      dynamodb.put_item({
        table_name: 'DEVICE_TO_CUSTOMER',
        condition_expression: 'attribute_not_exists(DEVICE_UUID)',
        item: {
          'DEVICE_UUID' => serial.to_s,
          'CUSTOMER_UUID' => uid.to_s
        }
      })
    rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
      return false
    end
    true
  end
end
