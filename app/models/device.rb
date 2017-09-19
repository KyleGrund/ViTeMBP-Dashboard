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
        table_name=>'DEVICE_TO_CUSTOMER',
        key: {
            'CUSTOMER_UUID' => uuid
        }).items
  end

end
