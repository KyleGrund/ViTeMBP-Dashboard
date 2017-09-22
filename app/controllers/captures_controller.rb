class CapturesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, :except => [:index]

  def index
    @captures = nil
  end

  def show
    @id = @user.id.to_s
    @captures = Capture.get_captures_for_user(@user.uid)
  end
end
