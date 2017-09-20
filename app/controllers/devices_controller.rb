class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, :except => [:index]

  def show
  end

  def register
    @id = @user.id
  end

  def details
    @to_display = Device.get_devices(@user.uid)
  end

  def adddevice
    serial = params[:devserial]
    @is_registered = Device.is_device_registered(serial)
    @registered_user = nil
    @registered_user = Device.get_user_registered_to(serial) unless @is_registered.nil?
  end
end
