# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
RnaSeqAnalysisPipeline::Application.initialize!



class Logger
  def format_message(level, time, progname, msg)
    "#{time.to_s(:db)} #{level} -- #{msg}\n"
  end
end

# class Logger
#   def format_message(level, time, progname, msg)
#     if msg =~ /"piece"=>"0"/
#       old_total = @total
#       old_view = @view
#       old_ar = @ar
#       @total = 0.0
#       @view = 0.0
#       @ar = 0.0
#       return "Old Query: total=#{old_total}, View=#{old_view}, AR=#{old_ar}\n"
#     end
#     if @print_next_msg == true
#       @print_next_msg = false
#       total, view, ar = msg.match(/Completed 200 OK in (.+)ms \(Views: (.+)ms \| ActiveRecord: (.+)ms\)/).captures
#       @total += total.to_f
#       @view += view.to_f
#       @ar += ar.to_f
#       #return "#{time.to_s(:db)} #{level} -- #{msg}\n"
#       return ""
#     elsif msg =~ /_table_rows.html.erb/
#       @print_next_msg = true
#       return ""
#     end
#   end
# end
