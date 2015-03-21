require "serial_connection"
require "bitmap"
require "print_mode"
require "barcode"
require "status"

class A2Printer

  DEFAULT_RESOLUTION = 7
  ESC_SEQUENCE = 27
  CONTROL_PARAMETERS = 55
  LINE_FEED = 10
  CARRIAGE_RETURN = "\n"
  NOT_ALLOWED_CHAR = 0x13
  UNDERLINES = {
    none: 0,
    normal: 1,
    thick: 2
  }

  MAXIMUM_WIDTH = 384

  def initialize(connection)
    @connection = connection
    @print_mode = PrintMode.new @connection
    @barcode = Barcode.new @connection
    @status = Status.new @connection
  end

  def begin(heat_time)
    reset()
    set_control_parameters heat_time
    modify_density(calculate_density_setting)
  end

  def reset
    @status.reset   
  end

  def reset_formatting
    online
    normal
    underline_off
    justify(:left)
    set_default_heights
  end

  def feed(lines=1)
    lines.times { line_feed }
  end

  def feed_rows(rows = 0)
    write_bytes(ESC_SEQUENCE, 74, rows)
  end

  def flush
    write_bytes(12)
  end

  def test_page
    write_bytes(18, 84)
  end

  def print(string)
    string.bytes { |char_as_byte| write(char_as_byte) }
  end

  def println(string)
    print(string + CARRIAGE_RETURN)
  end

  def write(char)
    return if not_allowed? char
    write_bytes(char)
  end

  def set_size(size)
    bytes = {
      small: 0,
      medium: 10,
      large: 25
    }

    write_bytes(29, 33, bytes[size], 10)
  end

  def underline_on(weight)
    weight = sanitized_weight weight
    write_bytes(ESC_SEQUENCE, 45, weight)
  end

  def underline_off
    underline_on(UNDERLINES[:none])
  end

  def justify(position)
    bytes = {
      left: 0,
      center: 1,
      right: 2
    }

    write_bytes(0x1B, 0x61, bytes[position])
  end

  def print_bitmap(*args)
    bitmap = obtain_bitmap *args

    return if bitmap.wider_than? MAXIMUM_WIDTH
    bitmap.print @connection
  end

  def set_barcode_height(val)
    @barcode.height val  
  end

  def print_barcode(text, type)
    @barcode.print text, type
  end
  
  def offline
    @status.offline
  end
  
  def online
    @status.online
  end
  
  def sleep
    @status.sleep_after 0
  end
 
  def sleep_after(seconds)
    @status.sleep_after seconds
  end

  def wake
    @status.wake
  end

  def set_default
    reset_formatting
  end

  private

  def line_feed
    write(LINE_FEED)
  end

  def set_default_heights
    default_for_line = 32
    set_line_height(default_for_line)

    @barcode.default_height
  end

  def modify_density setting
    write_bytes(18, 35)
    write_bytes(setting)
  end

  def calculate_density_setting
    density = 15
    break_time = 15
    (density << 4) | break_time
  end

  def set_heat_conditions heat_time
    heat_time = 150 if heat_time.nil?
    heat_interval = 50
    write_bytes(heat_time)
    write_bytes(heat_interval)
  end

  def set_default_resolution
    write_bytes(DEFAULT_RESOLUTION)
  end

  def set_control_parameters heat_time
    write_bytes(ESC_SEQUENCE, CONTROL_PARAMETERS)
    set_default_resolution
    set_heat_conditions heat_time
  end

  def not_allowed? char
    char == NOT_ALLOWED_CHAR
  end

  def write_bytes(*bytes)
    @connection.write_bytes *bytes
  end

  def normal
    @print_mode.normal
  end

  def sanitized_weight weight
    result = weight
    result = UNDERLINES[:none] if weight.nil?
    result = UNDERLINES[:thick] if weight > UNDERLINES[:thick]
    result
  end

  def obtain_bitmap *args
    only_source_provided = (args.size == 1)

    if only_source_provided
      source = args[0]
      bitmap = Bitmap.from_source source
    else
      bitmap = Bitmap.new *args
    end
    bitmap
  end
end
