class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, :except => [:index]

  def show
    @to_display = Device.get_devices(@user.uid)
  end

  def register
    @id = @user.id
  end

  def details
    @to_display = Device.get_devices(@user.uid)
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
