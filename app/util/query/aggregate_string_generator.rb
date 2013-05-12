class AggregrateStringGenerator
  
  attr_accessor :column
  attr_accessor :aggregate_name
  
  def initialize(column, aggregate_name = nil)
    @column = column
    @aggregate_name = aggregate_name
  end
  
  def generate_aggregate_string()
    agg_string = ''
    adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
    case adapter_type
    when /mysql/
      agg_string += "group_concat(#{@column} SEPARATOR ';')"
    when /postgresql/
      #TODO: Make sure these work
      select_string += "string_agg(#{@column},';')"
    else
      throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
    end
    if not @aggregate_name.nil?
      @agg_string += " as #{@aggregate_name}"
    end
    return agg_string
  end
end