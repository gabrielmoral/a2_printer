class Configuration
	
  ESC_SEQUENCE = 27  
  CONTROL_PARAMETERS = 55
  DEFAULT_RESOLUTION = 7

	def initialize connection
    @connection = connection
  end

  def configure heat_time
    set_control_parameters heat_time
    modify_density(calculate_density_setting)
  end

  private

  def set_control_parameters heat_time
    @connection.write_bytes(ESC_SEQUENCE, CONTROL_PARAMETERS)
    default_resolution
    heat_conditions heat_time
  end

  def default_resolution
    @connection.write_bytes(DEFAULT_RESOLUTION)
  end

  def heat_conditions heat_time
    heat_time = 150 if heat_time.nil?
    heat_interval = 50
    write_heat_conditions heat_time, heat_interval
  end

  def write_heat_conditions heat_time, heat_interval
    @connection.write_bytes(heat_time)
    @connection.write_bytes(heat_interval)
  end


  def modify_density setting
    @connection.write_bytes(18, 35)
    @connection.write_bytes(setting)
  end

  def calculate_density_setting
    density = 15
    break_time = 15
    (density << 4) | break_time
  end


end