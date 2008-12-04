require 'eve_corplogo_generator'
require 'test/unit'
require 'ftools'
class EveCorplogoGeneratorTest < Test::Unit::TestCase
  def setup
    @f = File.join(['out','test.png'])
    if File.exists?(@f) then 
      File.delete(@f)
    end
    @logo = Eve::CorporateLogo::Logo.new([437,456,478],[674,677,677],@f,'white')
  end
  def test_load
    assert_instance_of Eve::CorporateLogo::Logo, @logo
  end
  def test_file_output
    assert_equal true,File.exists?(@f)
  end
end