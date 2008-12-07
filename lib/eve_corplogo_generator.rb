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
        @output = output_path
        @layers = []
        @colors = colors.reverse # Reverse because we're constructing back-first, whereas API provides front-first lists.
        @shapes = shapes.reverse # And shapes too...
        @shapes.each_with_index{|v,k|@layers.push(Layer.new(v,@colors[k]))} # Build layers
        @image = Magick::Image.new(64,64){self.format='PNG';if fill then self.background_color=fill;end} 
        @layers.each do |l|
          @image = @image.composite(l.image,0,0,Magick::OverCompositeOp)
        end
        # Begin clever stuff to get transparency right.
        @image.view(0,0,64,64) do |v|
          l1 = @layers[0].image.view(0,0,64,64)
          l2 = @layers[1].image.view(0,0,64,64)
          l3 = @layers[2].image.view(0,0,64,64)
          (0..63).each do |x|
            (0..63).each do |y|
              r,g,b,a = v[x][y].red, v[x][y].green, v[x][y].blue, v[x][y].opacity
              a1 = (Magick::QuantumRange - l1[x][y].opacity) / Magick::QuantumRange
              a2 = (Magick::QuantumRange - l2[x][y].opacity) / Magick::QuantumRange
              a3 = (Magick::QuantumRange - l3[x][y].opacity) / Magick::QuantumRange
              a = 1-(a1*a2*a3)
              if a
                v[x][y].red = (r/a).round
                v[x][y].green = (g/a).round
                v[x][y].blue = (b/a).round
                v[x][y].opacity = (Magick::QuantumRange*a).round
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
      def initialize(shape,color)
        if shape > 0
          shape_filename = "src/#{color}/#{shape}.png"
          @image = Magick::Image::read(shape_filename).first
        else
          @image = Magick::Image.new(64,64){self.format='PNG'} # Blank image for a blank layer.
        end
      end
    end # Layer class
  end # CorporateLogo module
end # Nexus module