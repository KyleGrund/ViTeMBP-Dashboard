class CapturesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, :except => [:index]

  def index
    @captures = nil
  end

  def show
    @capture_details = Hash.new
  end
end
