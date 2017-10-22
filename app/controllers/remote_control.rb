
require 'time'

class RemoteControl
  # sends a message to the remote system
  def self.send_message(message_body, dev_id)
    queue_url = Rails.application.secrets.sqs_dev_queue_url + dev_id
    sqs = Aws::SQS::Client.new
    sqs.send_message(
      queue_url: queue_url,
      message_body: message_body
    )
    return
  end

  # sends a message to the remote system and returns a response
  def self.send_message_with_response(message_body, dev_id)
    msg_uuid = SecureRandom.uuid
    resp_uuid = SecureRandom.uuid

    write_data_entry msg_uuid, resp_uuid + ' ' + message_body
    send_sqs_message 'fromuuid ' + msg_uuid, dev_id
    return resp_uuid
  end

  # gets a response from the location
  def self.wait_for_response(location)
    Time start = Time.now
    timeout = 20;
    data = read_data_entry location

    while data.blank?
      if Time.now - start > timeout
        return
      else
        sleep(0.1)
        data = read_data_entry location
      end
    end
    data
  end

  # writes a data entry to the database
  def self.write_data_entry(location, value)
    # update the device entry with the current user's uuid so long as
    # there isn't already another value bound to it.
    dynamodb = Aws::DynamoDB::Client.new
    dynamodb.put_item(
      table_name: 'DATA',
      item: {
        'ID' => location,
        'VALUE' => value
      }
    )
    return
  end

  # reads a data entry from the database
  def self.read_data_entry(location)
    # gets row in the data table which matches the uuid
    dynamodb = Aws::DynamoDB::Client.new
    dynamodb.get_item(
      table_name: 'DATA',
      filter_expression: 'ID = :ID',
      expression_attribute_values: {
          ':ID' => location
    }).item['VALUE']
  end

  # writes a message to the device's message queue
  def self.send_sqs_message(message_body, dev_id)
    queue_url = Rails.application.secrets.sqs_dev_queue_url + dev_id
    sqs = Aws::SQS::Client.new
    sqs.send_message(
      queue_url: queue_url,
      message_body: message_body
    )
  end
end