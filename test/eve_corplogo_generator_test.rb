require 'eve_corplogo_generator'
require 'test/unit'
require 'ftools'
class EveCorplogoGeneratorTest < Test::Unit::TestCase
  def setup
    @f = File.join(['out','test.png'])
    if File.exists?(@f) then 
      File.delete(@f)
    end
    @fic = File.join(['out','test_ic.png'])
    if File.exists?(@fic) then 
      File.delete(@fic)
    end
    @logo = Eve::CorporateLogo::Logo.new([437,456,478],[674,677,677],@f)
    @incomplete_logo = Eve::CorporateLogo::Logo.new([437,0,478],[674,0,677],@fic)
  end
  def test_load
    assert_instance_of Eve::CorporateLogo::Logo, @logo
  end
  def test_file_output
    assert_equal true,File.exists?(@f)
  end
  def test_incomplete_load
    assert_instance_of Eve::CorporateLogo::Logo, @incomplete_logo
  end
  def test_incomplete_output
    assert_equal true,File.exists?(@fic)
  end
end

