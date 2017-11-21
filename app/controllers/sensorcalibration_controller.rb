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
    sensor_list = RemoteControl.send_message_with_response('LISTSENSORS', @dev_id)
    if sensor_list.blank?
      redirect_to '/' + @id + '/devices/details/' + @dev_serial, alert: 'Could not communicate with remote system. Check that it is online.'
      return
    end

    # parse sensor list for view
    @sensors = JSON.parse(sensor_list)
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
    if start_cal_resp.blank?
      redirect_to '/' + @id + '/sensor_calibration/' + @dev_serial + '/list', alert: 'Could not communicate with remote system. Check that it is online.'
      return
    end

    # check cal status
    cal_status = JSON.parse(RemoteControl.send_message_with_response 'CALSTATUS', @dev_serial)
    if cal_status.blank?
      redirect_to '/' + @id + '/sensor_calibration/' + @dev_serial + '/list', alert: 'Could not communicate with remote system. Check that it is online.'
      return
    end

    # check that the calibration started
    if !cal_status['isCalibrating']
      redirect_to '/' + @id + '/sensor_calibration/' + @dev_serial + '/list', alert: 'Calibration not started, device response: ' + start_cal_resp
      return
    end

    # the user prompt instructing the current calibration step procedure
    @user_prompt = cal_status['stepPrompt']
  end

  def next_step
    @id = @user.id.to_s

    @dev_serial = params[:devid]
    device = Device.get_device_config(@dev_serial,@user.uid)

    # make sure device ID is valid
    if device.nil?
      redirect_to '/' + @id + '/devices', alert: 'Unknown device.'
      return
    end

    # send start command
    next_step_resp = RemoteControl.send_message_with_response 'CALNEXTSTEP', @dev_serial
    if next_step_resp.blank?
      redirect_to '/' + @id + '/sensor_calibration/' + @dev_serial + '/list', alert: 'Could not communicate with remote system. Check that it is online.'
      return
    end

    # check cal status
    cal_status = JSON.parse(RemoteControl.send_message_with_response 'CALSTATUS', @dev_serial)
    if cal_status.blank?
      redirect_to '/' + @id + '/sensor_calibration/' + @dev_serial + '/list', alert: 'Could not communicate with remote system. Check that it is online.'
      return
    end

    # check that the calibration started
    if !cal_status['isCalibrating']
      redirect_to '/' + @id + '/sensor_calibration/' + @dev_serial + '/list', notice: 'Calibration completed: ' + next_step_resp
      return
    end

    # get sensor name and user prompt instructing the current calibration step procedure
    @sensor_name = cal_status['sensorName']
    @user_prompt = cal_status['stepPrompt']
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
