# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
RnaSeqAnalysisPipeline::Application.initialize!



# class Logger
#  def format_message(level, time, progname, msg)
#    "#{time.to_s(:db)} #{level} -- #{msg}\n"
#  end
# end

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

class Logger
 def format_message(level, time, progname, msg)
   if msg =~ /"piece"=>"0"/
     if not @count.nil?
       avg_total = @total/@count
       avg_view = @view/@count
       avg_ar = @ar/@count
       msg += "\nOld Query: total=#{avg_total}, View=#{avg_view}, AR=#{avg_ar}\n"
     end
     @total = 0.0
     @count = 0.0
     @view = 0.0
     @ar = 0.0
     return "#{time.to_s(:db)} #{level} -- #{msg}\n"
   end
   if @capture_next_msg == true
     @capture_next_msg = false
     total, view, ar = msg.match(/Completed 200 OK in (.+)ms \(Views: (.+)ms \| ActiveRecord: (.+)ms\)/).captures
     @count += 1.0
     @total += total.to_f
     @view += view.to_f
     @ar += ar.to_f
     #return "#{time.to_s(:db)} #{level} -- #{msg}\n"
   elsif msg =~ /_table_rows.html.erb/
     @capture_next_msg = true
   end
   return "#{time.to_s(:db)} #{level} -- #{msg}\n"
 end
end
