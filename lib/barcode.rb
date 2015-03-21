class Barcode

  UPC_A   = 0
  UPC_E   = 1
  EAN13   = 2
  EAN8    = 3
  CODE39  = 4
  I25     = 5
  CODEBAR = 6
  CODE93  = 7
  CODE128 = 8
  CODE11  = 9
  MSI     = 10

  DEFAULT_HEIGHT = 50

  def initialize connection
    @connection = connection
  end

  def default_height
    set_barcode_height DEFAULT_HEIGHT
  end

  def set_barcode_height value  
    @connection.write_bytes(29, 104, value)
  end

  def print_barcode text, type
    @connection.write_bytes(29, 107, type) 
    @connection.write_bytes(text.bytes)
    @connection.write_bytes(0)
  end

end