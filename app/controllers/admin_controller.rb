class AdminController < ApplicationController
  before_filter :authenticate_admin_user!
  
  def view_user_information
  end

  def delete_datasets_from_database
  end
  
  def view_unconfirmed_users
  end
  
  def confirm_user
    @user = User.find_by_id(params[:user_id])
    if (@user.id)
      flash[:alert] = 'Please select an unconfirmed user'
      redirect_to :view_unconfirmed_users
    end
  end
  
  def delete_user
    @user = User.find_by_id(params[:user_id])
    if (@user.id)
      flash[:alert] = 'Please select an unconfirmed user'
      redirect_to :view_unconfirmed_users
    end
  end
  
  private
  def authenticate_admin_user!
     if not current_user.admin?
      flash[:alert] = "Only administrators are allowed in this area."
      redirect_to root_path 
    end
  end
end
