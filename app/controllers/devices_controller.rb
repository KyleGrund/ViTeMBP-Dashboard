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
    Device.register_device(serial, @user.uid)
    unless @success
      if Device.is_device_registered(serial)
        redirect_to :register, :alert => "Could not add device, device is already registered."
      else
        redirect_to :register, :alert => "Could not add device, check serial number and try again."
      end
    end
    redirect_to :register, :notice => "Device successfully added."
  end
end
