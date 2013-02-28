class AdminController < ApplicationController
  require 'admin/confirm_user'
  require 'admin/delete_unconfirmed_user'
  
  before_filter :authenticate_admin_user!
  
  def welcome
  end
  
  def delete_datasets_from_database
    if request.get?
    elsif request.delete?
    end
  end
  
  def view_confirmed_users
  end
  
  def view_unconfirmed_users
    @unconfirmed_users = User.where(:confirmed_at => nil)
  end
  
  def confirm_user
    if request.get?
      @user = User.find_by_id(params[:user_id])
      if (@user.nil?)
        flash[:alert] = 'Please select an unconfirmed user'
        redirect_to :action => 'view_unconfirmed_users'
      end
      @confirm_user = Confirm_User.new()
    elsif request.post?
      @confirm_user = Confirm_User.new(params[:confirm_user])
      @confirm_user.send_confirmation_emails!
      flash[:notice] = 'Emails successfully sent'
      redirect_to :action => 'view_unconfirmed_users'
    end
  end
  
  def delete_unconfirmed_user
    @user = User.find_by_id(params[:user_id])
    if (@user.id)
      flash[:alert] = 'Please select an unconfirmed user'
      redirect_to :view_unconfirmed_users
    end
  end
  
  def welcome
    #This action is in the architecture design document
  end
  
  private
  def authenticate_admin_user!
    authenticate_user! 
    if not current_user.admin?
      flash[:alert] = "Only administrators are allowed in the admin area."
      redirect_to root_path 
    end
  end
end
