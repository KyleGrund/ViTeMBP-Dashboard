class SensorcalibrationController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?

  def list
    @id = @user.id.to_s

    @dev_id = params[:devid]
    device = Device.get_device_config(@dev_id,@user.uid)

    # make sure device ID is valid
    if device.nil?
      redirect_to '/' + @user.id.to_s + '/devices', alert: 'Unknown device.'
      return
    end

    # get list of sensors
    @sensors = JSON.parse(RemoteControl.send_message_with_response('LISTSENSORS', @dev_id))
  end

  def start
  end

  def next_step
  end

  def status
    @id = @user.id.to_s

    @dev_serial = params[:devid]
    device = Device.get_device_config(@dev_serial,@user.uid)

    # make sure device ID is valid
    if device.nil?
      redirect_to '/' + @id + '/devices', alert: 'Unknown device.'
      return
    end

    # get list of sensors
    cal_status = RemoteControl.send_message_with_response 'CALSTATUS', serial

    # just return the data from the response instead of rendering a view
    respond_to do |format|
      format.html { render :plain => cal_status }
    end
  end
end
