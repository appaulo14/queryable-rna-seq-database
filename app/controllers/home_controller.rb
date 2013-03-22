require 'home/report_issue.rb'

class HomeController < ApplicationController
    def welcome
    end
    
    def report_issue
      @current_user = current_user
      if request.get?
        @ri = ReportIssue.new(@current_user)
        @ri.set_attributes_and_defaults()
      elsif request.post?
        @ri = ReportIssue.new(@current_user)
        @ri.set_attributes_and_defaults(params[:report_issue])
        if @ri.valid_with_captcha? 
          @ri.report_issue()
          render :issue_reported_successfully 
        end
      end
    end
end
