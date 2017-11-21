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
    @id = @user.id.to_s

    @dev_serial = params[:devid]
    @sensor_name = params[:sensor]
    device = Device.get_device_config(@dev_serial,@user.uid)

    # make sure device ID is valid
    if device.nil?
      redirect_to '/' + @id + '/devices', alert: 'Unknown device.'
      return
    end

    # send start command
    start_cal_resp = RemoteControl.send_message_with_response 'CALSENSOR ' + @sensor_name, @dev_serial

    # check cal status
    cal_status = JSON.parse(RemoteControl.send_message_with_response 'CALSTATUS', @dev_serial)

    unless cal_status["isCalibrating"] == 'true'
      redirect_to '/' + @id + '/sensor_calibration/' + @dev_serial + "/list", alert: 'Calibration not started, device response: ' + start_cal_resp
    end
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

    # get sensor calibration status
    cal_status = RemoteControl.send_message_with_response 'CALSTATUS', @dev_serial

    # just return the data from the response instead of rendering a view
    respond_to do |format|
      format.html { render :plain => cal_status }
    end
  end
end
