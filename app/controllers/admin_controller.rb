class AdminController < ApplicationController
  before_filter :authenticate_admin_user!
  
  def view_user_information
  end

  def add_new_user_to_system
  end

  def delete_datasets_from_database
  end
  
  def view_unconfirmed_users
  end
  
  def confirm_or_delete_user
  end
  
  private
  def authenticate_admin_user!
     unless current_user.admin?
      flash[:alert] = "Only administrators are allowed in this area."
      redirect_to root_path 
    end
  end
end
