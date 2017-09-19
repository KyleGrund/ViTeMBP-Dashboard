class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, :except => [:index]

  def show
  end

  def register
  end

  def details
    @to_display = Device.get_devices(@user.uid)
  end
end
