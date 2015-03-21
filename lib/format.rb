class Format

  ESC_SEQUENCE = 27  
  UNDERLINES = {
    none: 0,
    normal: 1,
    thick: 2
  }

  def initialize connection
    @connection = connection
  end

  def size(size)
    bytes = {
      small: 0,
      medium: 10,
      large: 25
    }

    @connection.write_bytes(29, 33, bytes[size], 10)
  end

  def underline_on(weight)
    weight = sanitized_weight weight
    @connection.write_bytes(ESC_SEQUENCE, 45, weight)
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

    @connection.write_bytes(0x1B, 0x61, bytes[position])
  end

  def reset barcode, status, print_mode
    status.online
    print_mode.normal
    underline_off
    justify(:left)
    default_heights barcode
  end

  private 

  def sanitized_weight weight
    result = weight
    result = UNDERLINES[:none] if weight.nil?
    result = UNDERLINES[:thick] if weight > UNDERLINES[:thick]
    result
  end

   def default_heights barcode
    default_for_line = 32
    line_height(default_for_line)

    barcode.default_height
  end

  def line_height(value)
    @connection.write_bytes(27, 51, value)
  end



end