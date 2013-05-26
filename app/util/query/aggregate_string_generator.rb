# Utility class to create an aggegrate SQL select string for a given column 
# with the given aggregate name. It provides database abstraction by creating 
# a different string based on whether the database is MySQL or Postgresql. 
class AggregateStringGenerator
  
  # The name of the database column to aggregate
  attr_accessor :column
  # The name to give to the aggregate
  attr_accessor :aggregate_name
  
  ###
  # parameters::
  # * <b>column:</b> the name of the database column to aggregate
  # * <b>aggregate name (Optional):</b> the name to give to the aggregate
  def initialize(column, aggregate_name = nil)
    @column = column
    @aggregate_name = aggregate_name
  end
  
  ###
  # Generates and returns the actual aggregrate string
  def generate_aggregate_string()
    agg_string = ''
    adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
    case adapter_type
    when /mysql/
      agg_string += "group_concat(#{@column} SEPARATOR ';')"
    when /postgresql/
      agg_string += "string_agg(#{@column},';')"
    else
      throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
    end
    if not @aggregate_name.nil?
      agg_string += " as #{@aggregate_name}"
    end
    return agg_string
  end
end
