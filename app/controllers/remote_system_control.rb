
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
  def self.sendMessageWithResponse(message_body, dev_id)
    msg_uuid = SecureRandom.uuid
    resp_uuid = SecureRandom.uuid

    write_data_entry msg_uuid, resp_uuid + ' ' + message_body
    send_sqs_message 'fromuuid ' + msg_uuid, dev_id
    return resp_uuid
  end

  # gets a response from the location
  def self.getResponse(location)
    data = read_data_entry location
    data.blank? ? nil : data
  end

  private
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