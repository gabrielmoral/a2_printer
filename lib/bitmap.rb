require 'bitmap_size'

class Bitmap
    attr_reader

    def self.from_source connection, source
      data = obtain_data source
      width = obtain_width data
      height = obtain_heigth data
      new(connection, width, height, source)
    end

    def initialize(connection, width, height, source)
        @data = Bitmap.obtain_data(source)
        @bitmap_size = BitmapSize.new width, height
        @connection = connection
    end

    def wider_than? width
      @bitmap_size.width > width
    end

    def print 
      row_start = 0
      width_in_bytes = @bitmap_size.width_in_bytes

      while row_start < @bitmap_size.height do
        print_chunk_of_bitmap row_start, width_in_bytes
        row_start += 255
      end
    end

    private 

    def print_chunk_of_bitmap row_start, width_in_bytes
      chunk_height = @bitmap_size.chunk_height row_start     
      write_chunk_of_bitmap chunk_height, width_in_bytes
    end

    def write_chunk_of_bitmap chunk_height, width_in_bytes
      bytes = (0...(width_in_bytes * chunk_height)).map { @data.getbyte }

      @connection.write_bytes(18, 42)
      @connection.write_bytes(chunk_height, width_in_bytes)
      @connection.write_bytes(*bytes)
    end

    def self.obtain_data source
      if source.respond_to?(:getbyte)
        data = source
      else
        data = StringIO.new(source.map(&:chr).join)
      end
      data
    end

    def self.obtain_heigth data
      obtain_size data
    end

    def self.obtain_width data
      obtain_size data
    end

    def self.obtain_size data
      tmp = data.getbyte
      size = (data.getbyte << 8) + tmp
      size
    end
  end
