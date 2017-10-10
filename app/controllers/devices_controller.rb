class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?

  def show
    @id = @user.id.to_s

    @to_display = []
    Device.get_devices(@user.uid).each { |dev|
      if dev['CONFIG'].blank?
        @to_display.push(id: dev['ID'], name: 'Not Configured')
      else
        parse_config Nokogiri::XML::Document.parse(dev['CONFIG'])
        @to_display.push(id: dev['ID'], name: @device_name)
      end
    }
  end

  def register
    @id = @user.id
  end

  def details
    @id = @user.id.to_s
    serial = params[:devid]
    device = Device.get_device_config(serial,@user.uid)

    # make sure device ID is valid
    if device.nil?
      redirect_to '/' + @user.id.to_s + '/devices', alert: 'Unknown device.'
      return
    end

    @device_config = device['CONFIG'].to_s
    xml_config = Nokogiri::XML::Document.parse(@device_config)
    parse_config xml_config
    @device_id = device['ID']
    @device_changes_pending = device['UPDATED'] || 'false'
  end

  def update_details
    serial = params[:devid]
    device = Device.get_device_config(serial,@user.uid)

    # make sure device ID is valid
    if device.nil?
      redirect_to '/' + @user.id.to_s + '/devices', alert: 'Unknown device.'
      return
    end

    # make sure device configuration is defined
    @device_config = device['CONFIG']
    if device.blank?
      redirect_to '/' + @user.id.to_s + '/devices/details/' + serial, alert: 'Device must sync before configuration can be updated.'
      return
    end

    xml_config = Nokogiri::XML::Document.parse(@device_config)
    parse_config xml_config

    is_updated = false

    # check name
    new_device_name = params[:device_name].to_s
    if new_device_name.length > 100
      redirect_to '/' + @user.id.to_s + '/devices/details/' + serial, alert: 'Device name is too long.'
      return
    end
    if @device_name != new_device_name
      is_updated = true
      xml_config.at_xpath('/configuration/systemname').content = new_device_name
    end

    # check sampling frequency
    new_freq = params[:sampling_frequency].to_s.to_f
    if new_freq <= 0.0 || new_freq > 1000.0
      redirect_to '/' + @user.id.to_s + '/devices/details/' + serial, alert: 'Invalid sampling frequency.'
      return
    end

    if @sampling_frequency != new_freq
      is_updated = true
      xml_config.at_xpath('/configuration/samplingfrequency').content = new_freq.to_s
    end

    # check sensor names

    # check sensor bindings

    # if updated write to database
    if is_updated
      Device.write_device_config(serial, @user.uid, xml_config)
      redirect_to '/' + @user.id.to_s + '/devices/details/' + serial, notice: 'Device settings updated.'
      return
    else
      redirect_to '/' + @user.id.to_s + '/devices/details/' + serial, notice: 'No device settings updated.'
      return
    end
  end

  def adddevice
    serial = params[:devserial]

    if serial.blank?
      redirect_to '/' + @user.id.to_s + '/devices/register', alert: 'Could not add device, check serial number and try again.'
      return
    end

    success = Device.register_device(serial, @user.uid)
    if success
      redirect_to '/' + @user.id.to_s + '/devices/register', notice: 'Device successfully added.'
    else
      if Device.is_device_registered(serial)
        redirect_to '/' + @user.id.to_s + '/devices/register', alert: 'Could not add device, device is already registered.'
      else
        redirect_to '/' + @user.id.to_s + '/devices/register', alert: 'Could not add device, check serial number and try again.'
      end
    end
  end

  def parse_config(xml_config)
    @device_name = xml_config.at_xpath('/configuration/systemname').content
    @sampling_frequency = xml_config.at_xpath('/configuration/samplingfrequency').content.to_f
    @sensor_names = xml_config.xpath('/configuration/sensornames/name')
    @sensor_bindings = xml_config.xpath('/configuration/sensorbindings/sensorbinding')
  end
end
