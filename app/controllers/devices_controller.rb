class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, :except => [:index]

  def show
  end

  def register
  end
end
