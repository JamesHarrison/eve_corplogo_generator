require 'rubygems'
require 'fastercsv'
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
      def initialize(shapes,colors,output_path,fill)
        @output = output_path.to_s
        @layers = []
        @colors = colors.reverse # Reverse because we're constructing back-first, whereas API provides front-first lists.
        @shapes = shapes.reverse # And shapes too...
        @shapes.each_with_index{|v,k|if v > 0 {@layers.push(Layer.new(v,@colors[k]))}} # Build layers
        @image = Magick::Image.new(64,64){self.format='PNG';self.background_color=fill;}
        @layers.each do |l|
          @image = @image.composite(l.image,0,0,Magick::OverCompositeOp)
        end
        File.open(output_path,"wb") do |f|
          f << @image.to_blob
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