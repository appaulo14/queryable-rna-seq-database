require 'admin/confirm_user'
require 'admin/delete_unconfirmed_user'

###
# Handles all actions related to administrative functions.
class AdminController < ApplicationController
  
  before_filter :authenticate_admin_user!
  
  ###
  # Displays all the users that have been confirmed
  def view_confirmed_users
    ut = User.arel_table
    @confirmed_users = User.where(ut[:confirmed_at].not_eq(nil))
  end
  
  ###
  # Displays all the users that have not been confirmed
  def view_unconfirmed_users
    @unconfirmed_users = User.where(:confirmed_at => nil)
  end
  
  ###
  # Handles all the GET and POST requests for the confirm user page
  def confirm_user
    if request.get?
      @confirm_user = ConfirmUser.new({:user_id => params[:user_id]})
      if not @confirm_user.valid?
        flash[:alert] = 'Select an unconfirmed user'
        redirect_to :action => 'view_unconfirmed_users'
      end
    elsif request.post?
      @confirm_user = ConfirmUser.new(params[:confirm_user])
      if @confirm_user.valid?
        @confirm_user.send_confirmation_emails
        flash[:notice] = 'Emails successfully sent'
        redirect_to :action => 'view_unconfirmed_users'
      end
    end
  end
  
  ###
  # Handles all the GET and POST requests for the delete unconfirmed user page
  def delete_unconfirmed_user
    if request.get?
      @delete_unconfirmed_user = 
          DeleteUnconfirmedUser.new({:user_id => params[:user_id]})
      if not @delete_unconfirmed_user.valid?
        flash[:alert] = 'Select an unconfirmed user'
        redirect_to :action => 'view_unconfirmed_users'
      end
    elsif request.post?
      @delete_unconfirmed_user = 
          DeleteUnconfirmedUser.new(params[:delete_unconfirmed_user])
      if @delete_unconfirmed_user.valid?
        @delete_unconfirmed_user.send_rejection_email_and_delete_user()
        flash[:notice] = 'Email successfully sent and user deleted'
        redirect_to :action => 'view_unconfirmed_users'
      end
    end
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
