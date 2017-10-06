class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?

  def show
    @id = @user.id.to_s
    @to_display = Device.get_devices(@user.uid)
  end

  def register
    @id = @user.id
  end

  def details
    serial = params[:devserial]
    device = Device.get_device_config(serial,@user.uid)

    if device.nil?
      redirect_to '/' + @user.id.to_s + '/devices', :alert => "Unknown device."
    end

    @device_config = device['CONFIG'] || 'No Configuration Saved.'
    @device_id = device['ID']
    @device_changes_pending = device['UPDATED'] || 'false'
  end

  def adddevice
    serial = params[:devserial]
    success = Device.register_device(serial, @user.uid)
    if success
      redirect_to "/" + @user.id.to_s + "/devices/register", :notice => "Device successfully added."
    else
      if Device.is_device_registered(serial)
        redirect_to "/" + @user.id.to_s + "/devices/register", :alert => "Could not add device, device is already registered."
      else
        redirect_to "/" + @user.id.to_s + "/devices/register", :alert => "Could not add device, check serial number and try again."
      end
    end
  end
end
