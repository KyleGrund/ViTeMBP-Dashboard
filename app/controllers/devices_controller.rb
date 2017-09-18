class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, :except => [:index]

  def list
  end

  def register
  end
end
