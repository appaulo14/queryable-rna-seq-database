###
# The base class for all other controllers in the project.
class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers
  protect_from_forgery
end
