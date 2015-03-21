class Bitmap
    attr_reader

    def self.from_source source
      data = obtain_data source
      width = obtain_width data
      height = obtain_heigth data
      new(width, height, source)
    end

    def initialize(width, height, source)
        @data = Bitmap.obtain_data(source)
        @width = width
        @height = height
    end

    def wider_than? width
      @width > width
    end

    def print connection
      row_start = 0
      width_in_bytes = @width / 8

      while row_start < @height do
        
        chunk_height = chunk_height row_start
        bytes = (0...(width_in_bytes * chunk_height)).map { @data.getbyte }

        connection.write_bytes(18, 42)
        connection.write_bytes(chunk_height, width_in_bytes)
        connection.write_bytes(*bytes)
        row_start += 255
      end
    end

    private  

    def chunk_height row_start
      ((@height - row_start) > 255) ? 255 : (@height - row_start)
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
