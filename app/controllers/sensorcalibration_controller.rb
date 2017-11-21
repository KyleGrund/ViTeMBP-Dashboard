class SensorcalibrationController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?

  def list
    @id = @user.id.to_s

    serial = params[:devid]
    device = Device.get_device_config(serial,@user.uid)

    # make sure device ID is valid
    if device.nil?
      redirect_to '/' + @user.id.to_s + '/devices', alert: 'Unknown device.'
      return
    end

    # get list of sensors
    @sensors = JSON.parse(RemoteControl.send_message_with_response 'LISTSENSORS', serial)
  end

  def start
  end

  def next_step
  end
end
