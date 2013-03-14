class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]

  # GET /resource/sign_up
  def new
    resource = build_resource({})
    respond_with resource
  end

  # POST /resource
  def create
    build_resource
    #Validate captcha
    if not simple_captcha_valid?
      #TODO: Move this flash alert to error messages array instead?
      flash[:alert] = 'Captcha failed'
      redirect_to '/'
      return
    end
    #Mark the user as confirmed already so that a confirmation email 
    #   won't be automatically sent when the user is saved
    resource.skip_confirmation!
    if resource.save
      #Mark the user as unconfirmed so that they can't log in
      #The admin will manually trigger the confirmation email later
      resource.confirmed_at = nil
      resource.save!
      #Notify the admin that about the registration request
      RegistrationMailer.notify_admin_of_registration_request_email(resource).deliver
#       if resource.active_for_authentication?
#         set_flash_message :notice, :signed_up if is_navigational_format?
#         sign_up(resource_name, resource)
#         respond_with resource, :location => after_sign_up_path_for(resource)
#       else
        #set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
      flash[:notice] = "The admin has been notified of your request." if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
#       end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  # GET /resource/edit
  def edit
    render :edit
  end

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
# 
#   # DELETE /resource
#   def destroy
#     resource.destroy
#     Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
#     set_flash_message :notice, :destroyed if is_navigational_format?
#     respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
#   end
# 
#   # GET /resource/cancel
#   # Forces the session data which is usually expired after sign
#   # in to be expired now. This is useful if the user wants to
#   # cancel oauth signing in/up in the middle of the process,
#   # removing all OAuth session data.
#   def cancel
#     expire_session_data_after_sign_in!
#     redirect_to new_registration_path(resource_name)
#   end
# 
#   protected
# 
#   def update_needs_confirmation?(resource, previous)
#     resource.respond_to?(:pending_reconfirmation?) &&
#       resource.pending_reconfirmation? &&
#       previous != resource.unconfirmed_email
#   end
# 
#   # Build a devise resource passing in the session. Useful to move
#   # temporary session data to the newly created user.
#   def build_resource(hash=nil)
#     hash ||= resource_params || {}
#     self.resource = resource_class.new_with_session(hash, session)
#   end
# 
#   # Signs in a user on sign up. You can overwrite this method in your own
#   # RegistrationsController.
#   def sign_up(resource_name, resource)
#     sign_in(resource_name, resource)
#   end
# 
#   # The path used after sign up. You need to overwrite this method
#   # in your own RegistrationsController.
#   def after_sign_up_path_for(resource)
#     after_sign_in_path_for(resource)
#   end
# 
#   # The path used after sign up for inactive accounts. You need to overwrite
#   # this method in your own RegistrationsController.
#   def after_inactive_sign_up_path_for(resource)
#     respond_to?(:root_path) ? root_path : "/"
#   end
# 
#   # The default url to be used after updating a resource. You need to overwrite
#   # this method in your own RegistrationsController.
#   def after_update_path_for(resource)
#     signed_in_root_path(resource)
#   end
# 
#   # Authenticates the current scope and gets the current resource from the session.
#   def authenticate_scope!
#     send(:"authenticate_#{resource_name}!", :force => true)
#     self.resource = send(:"current_#{resource_name}")
#   end
end
