require "serial_connection"
require "bitmap"
require "print_mode"
require "barcode"
require "status"
require "format"
require "configuration"

class A2Printer

  ESC_SEQUENCE = 27
  LINE_FEED = 10
  CARRIAGE_RETURN = "\n"
  NOT_ALLOWED_CHAR = 0x13

  MAXIMUM_WIDTH = 384

  def initialize(connection)
    @connection = connection
    @print_mode = PrintMode.new @connection
    @barcode = Barcode.new @connection
    @status = Status.new @connection
    @format = Format.new @connection   
    
    @collaborators = [@print_mode, @barcode, @status, @format]
  end

  def begin(heat_time)
    reset
    configure_printer heat_time
  end

  def configure_printer heat_time
    configuration = Configuration.new @connection
    configuration.configure heat_time
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

  def print_bitmap(*args)
    bitmap = obtain_bitmap *args

    return if bitmap.wider_than? MAXIMUM_WIDTH
    bitmap.print
  end 
   
  def set_default
    reset_formatting @barcode, @status, @print_mode
  end

  private

  def line_feed
    write(LINE_FEED)
  end

  def not_allowed? char
    char == NOT_ALLOWED_CHAR
  end

  def write_bytes(*bytes)
    @connection.write_bytes *bytes
  end

  def obtain_bitmap *args
    only_source_provided = (args.size == 1)

    if only_source_provided
      source = args[0]
      bitmap = Bitmap.from_source @connection, source
    else
      bitmap = Bitmap.new @connection, *args
    end
    bitmap
  end

   def method_missing sym, *args, &block
    method_is_called = false

    @collaborators.each { |collaborator| 
      if(collaborator.respond_to?(sym)) 
        collaborator.send(sym, *args, &block) 
        method_is_called = true    
        break
      end
    }
    raise NoMethodError.new("undefined method") unless method_is_called
  end

end
