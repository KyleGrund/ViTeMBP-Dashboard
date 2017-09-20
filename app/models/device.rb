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
    dynamodb.batch_get_item(
        table_name: 'DEVICE_TO_CUSTOMER',
        key: {
            'CUSTOMER_UUID' => uuid
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
      binding['CUSTOMER_UUID']
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
    dynamodb.put_item({
      table_name: 'Products',
      condition_expression: 'attribute_not_exists(product_id)',
      item: {
        'DEVICE_UUID' => serial.to_s,
        'CUSTOMER_UUID' => uid.to_s
      }
    })
  end
end
