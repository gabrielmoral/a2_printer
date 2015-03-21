class BitmapSize
	attr_reader :width, :height

	def initialize width, height
		@width = width
		@height = height
	end

	def width_in_bytes
		 @width / 8
	end

  def chunk_height row_start
    ((@height - row_start) > 255) ? 255 : (@height - row_start)
  end  
	
end