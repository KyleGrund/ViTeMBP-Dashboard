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

  def self.get_device_config(dev_uuid, user_uuid)
    # gets all rows in the devices table which match the customer's uuid
    dynamodb = Aws::DynamoDB::Client.new
    rows = dynamodb.scan({
                             table_name: 'DEVICES',
                             filter_expression: 'CUSTOMER_UUID = :CUSTOMER_UUID AND ID = :DEV_UUID',
                             expression_attribute_values: {
                                 ':DEV_UUID' => dev_uuid.to_s,
                                 ':CUSTOMER_UUID' => user_uuid.to_s
                             }
                         }).items || []

    # return just the first or nil if empty
    if rows.any?
      return rows.first
    else
      return nil
    end
  end

  def self.write_device_config(dev_uuid, user_uuid, config)
    # gets all rows in the devices table which match the customer's uuid
    dynamodb = Aws::DynamoDB::Client.new
    dynamodb.put_item({
        table_name: 'DEVICES',
        item: {
            'ID' => dev_uuid.to_s,
            'CONFIG' => config.to_s,
            'CUSTOMER_UUID' => user_uuid.to_s,
            'UPDATED' => 'true'
        },
        expected: {
            'ID' => {
                value: dev_uuid.to_s,
                exists: true
            },
            'CUSTOMER_UUID' => {
                value: user_uuid.to_s,
                exists: true
            }
        }
    })
  end

  def self.get_devices(uuid)
    # gets all rows in the devices table which match the customer's uuid
    dynamodb = Aws::DynamoDB::Client.new
    rows = dynamodb.scan({
        table_name: 'DEVICES',
        filter_expression: 'CUSTOMER_UUID = :CUSTOMER_UUID',
        expression_attribute_values: {
            ':CUSTOMER_UUID' => uuid.to_s
        }
      }).items || []

    # return just the device ids, not the rest of the data in the row
    devices = Array.new()
    rows.each { |dev| devices.push(dev['ID']) }
    devices
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
