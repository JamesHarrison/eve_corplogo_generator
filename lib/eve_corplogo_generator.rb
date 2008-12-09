require 'rubygems'
require 'RMagick'
module Eve
  module CorporateLogo
    # Represents a complete logo.
    # Attributes:
    #   image - The Magick::Image instance
    #   layers - Array of Layer instances
    #   output - Path to which the output of this Logo has been written
    class Logo 
      attr_accessor :image, :layers, :output
      def initialize(shapes,colors,output_path=nil,fill=nil)
        logger = Logger.new("log.txt")
        logger.level = Logger::DEBUG
        @output = output_path
        @layers = []
        @colors = colors.reverse # Reverse because we're constructing back-first, whereas API provides front-first lists.
        @shapes = shapes.reverse # And shapes too...
        @shapes.each_with_index{|v,k|@layers.push(Layer.new(v,@colors[k])) if v > 0} # Build layers
        @image = Magick::Image.new(64,64){self.format='PNG';self.background_color='none';} 
        @layers.each do |l|
          @image = @image.composite(l.image,0,0,Magick::OverCompositeOp)
        end
        # Begin clever stuff to get transparency right.
        @image.view(0,0,64,64) do |v|
          l1 = @layers[0].image.view(0,0,64,64) if @layers[0].image
          l2 = @layers[1].image.view(0,0,64,64) if @layers[1].image
          l3 = @layers[2].image.view(0,0,64,64) if @layers[2].image
          (0..63).each do |x|
            (0..63).each do |y|
              a1 = defined?(l1) ? l1[x][y].opacity : 255
              a2 = defined?(l2) ? l2[x][y].opacity : 255
              a3 = defined?(l3) ? l3[x][y].opacity : 255
              a = (a1*a2*a3)/(Magick::QuantumRange^3)
              if a > 0
                v[x][y].red = (v[x][y].red/a).round
                v[x][y].green = (v[x][y].green/a).round
                v[x][y].blue = (v[x][y].blue/a).round
                v[x][y].opacity = ((Magick::QuantumRange)*a).round
              end
            end
          end
        end
        if output_path
          File.open(output_path,"wb") do |f|
            f << @image.to_blob
          end
        end
      end
    end
    # Represents a layer of the logo. This is one image of the logo, of which some (Usually 3) are composited to form the logo.
    # Each layer may carry a different colour, or no colour at all
    class Layer
      attr_accessor :image
      if defined?(RAILS_ROOT)
        def initialize(shape,color)
          if shape > 0
            @image = Magick::Image::read("#{RAILS_ROOT}/vendor/plugins/eve_corplogo_generator/src/#{color}/#{shape}.png")[0]
          end
        end
      else
        def initialize(shape,color)
          if shape > 0
            @image = Magick::Image::read("src/#{color}/#{shape}.png")[0]
          end
        end
      end
    end # Layer class
  end # CorporateLogo module
end # Eve module