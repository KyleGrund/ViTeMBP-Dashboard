
require 'time'

class ServicesControl
  # sends a message to the remote system
  def self.send_message(message_body)
    queue_url = Rails.application.secrets.sqs_queue_url
    sqs = Aws::SQS::Client.new
    sqs.send_message(
      queue_url: queue_url,
      message_body: message_body
    )
    return
  end

  # sends a message to the remote system and returns a response
  def self.send_message_with_response(message_body)
    # create data locations for the command and response
    msg_uuid = SecureRandom.uuid
    resp_uuid = SecureRandom.uuid

    # send the message
    write_data_entry msg_uuid, resp_uuid + ' ' + message_body
    send_sqs_message 'fromuuid ' + msg_uuid

    # wait for a response
    resp = wait_for_response resp_uuid

    # clean up database
    if resp.blank?
      # if the response is blank the message was not received in time so delete it
      # there will be no response to delete
      delete_data_entry msg_uuid
    else
      # the message was successful so the remote device will delete the message and
      # as the receiver all we need to clean up is the response
      delete_data_entry resp_uuid
    end

    resp
  end

  # gets a response from the location
  def self.wait_for_response(location)
    start = Time.now
    timeout = 20;
    data = read_data_entry location

    while data.blank?
      if (Time.now - start) > timeout
        return nil
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
    resp = dynamodb.get_item(
      table_name: 'DATA',
      key: { 'ID' => location }
    )

    resp.blank? ? nil : resp.item['VALUE']
  end

  # deletes a data entry to the database
  def self.delete_data_entry(location)
    # update the device entry with the current user's uuid so long as
    # there isn't already another value bound to it.
    dynamodb = Aws::DynamoDB::Client.new
    dynamodb.delete_item(
      table_name: 'DATA',
      key: { 'ID' => location }
    )
    return
  end

  # writes a message to the device's message queue
  def self.send_sqs_message(message_body)
    queue_url = Rails.application.secrets.sqs_queue_url
    sqs = Aws::SQS::Client.new
    sqs.send_message(
      queue_url: queue_url,
      message_body: message_body
    )
  end
end