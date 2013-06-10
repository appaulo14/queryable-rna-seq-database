###
# A subclass of the Devise gem's registrations controller.  
# This subclass alters the registration process to fit with the requirements 
# for the project.
class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  
  ###
  # POST /resource
  def create
    build_resource
    #Mark the user as confirmed already so that a confirmation email 
    #   won't be automatically sent when the user is saved
    resource.skip_confirmation!
    if resource.valid_with_captcha?
      ActiveRecord::Base.transaction do
        resource.save!
        #Mark the user as unconfirmed so that they can't log in
        #The admin will manually trigger the confirmation email later
        resource.confirmed_at = nil
        resource.save!
        #Notify the admin that about the registration request
        RegistrationMailer.notify_admin_of_registration_request_email(resource)
      end
      flash[:notice] = "The admin has been notified of your request." if is_navigational_format?
      expire_session_data_after_sign_in!
      respond_with resource, :location => after_inactive_sign_up_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  ###
  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    resource_params.delete(:email) #Ensure user can't change their email
    if resource.update_with_password(resource_params)
      if is_navigational_format?
        flash_key = :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
end
