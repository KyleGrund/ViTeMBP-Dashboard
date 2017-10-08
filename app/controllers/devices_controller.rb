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
    serial = params[:devid]
    device = Device.get_device_config(serial,@user.uid)

    if device.nil?
      redirect_to '/' + @user.id.to_s + '/devices', :alert => 'Unknown device.'
      return
    end

    @device_config = device['CONFIG']
    parse_config @device_config
    @device_id = device['ID']
    @device_changes_pending = device['UPDATED'] || 'false'
  end

  def update_details

  end

  def adddevice
    serial = params[:devserial]
    success = Device.register_device(serial, @user.uid)
    if success
      redirect_to '/' + @user.id.to_s + '/devices/register', :notice => 'Device successfully added.'
    else
      if Device.is_device_registered(serial)
        redirect_to '/' + @user.id.to_s + '/devices/register', :alert => 'Could not add device, device is already registered.'
      else
        redirect_to '/' + @user.id.to_s + '/devices/register', :alert => 'Could not add device, check serial number and try again.'
      end
    end
  end

  def parse_config(config)
    if config.nil?
      @device_name = ''
      @sampling_frequency = 0.0
      @sensor_names = []
      @sensor_bindings = {}
    else
      xml_config = Nokogiri::XML::Document.parse(config)
      @device_name = xml_config.at_xpath('/configuration/systemname').content
      @sampling_frequency = xml_config.at_xpath('/configuration/samplingfrequency').content.to_f
      @sensor_names = xml_config.xpath('/configuration/sensornames/name')
      @sensor_bindings = xml_config.xpath('/configuration/sensorbindings/sensorbinding')
    end
  end
end
