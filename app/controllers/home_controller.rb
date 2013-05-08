require 'home/report_issue.rb'

###
# Handles actions for the home page and reporting an issue.
class HomeController < ApplicationController
  ###
  # Displays the home page
  def welcome
  end
  
  ### 
  # Handles GET and POST requests for the report issue page
  def report_issue
    @current_user = current_user
    if request.get?
      @ri = ReportIssue.new(@current_user)
      @ri.set_attributes_and_defaults()
    elsif request.post?
      @ri = ReportIssue.new(@current_user)
      @ri.set_attributes_and_defaults(params[:report_issue])
      #Only validate the captcha if the user is not logged in
      if not current_user.nil?
        if @ri.valid? 
          @ri.report_issue()
          flash[:notice] = 'Issue reported successfully'
          redirect_to :action => 'welcome'
        end
      else
        if @ri.valid_with_captcha? 
          @ri.report_issue()
          flash[:notice] = 'Issue reported successfully'
          redirect_to :action => 'welcome'
        end
      end
    end
  end
end
