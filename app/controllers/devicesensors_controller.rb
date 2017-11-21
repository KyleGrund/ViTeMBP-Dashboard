class DevicesensorsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?

  def list
    @id = @user.id.to_s

    @dev_serial = params[:devid]
    device = Device.get_device_config(@dev_serial,@user.uid)

    # make sure device ID is valid
    if device.nil?
      redirect_to '/' + @id + '/devices', alert: 'Unknown device.'
      return
    end

    # get list of sensors
    sensors_list = RemoteControl.send_message_with_response 'LISTSENSORS', @dev_serial

    # just return the data from the response instead of rendering a view
    respond_to do |format|
      format.html { render :plain => sensors_list }
    end
  end
end
