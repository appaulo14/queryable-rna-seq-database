class ConfirmationsController < Devise::ConfirmationsController
  def new
    redirect_to '/'
  end
end
