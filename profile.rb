require 'rubygems'
require 'lib/eve_corplogo_generator'
require 'ruby-prof'
f = File.join(['out','test.png'])
if File.exists?(f) then 
  File.delete(f)
end
RubyProf.start
logo = Eve::CorporateLogo::Logo.new([437,456,478],[674,677,677],f,'white')
result = RubyProf.stop
# Print a flat profile to text
printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, 0)
