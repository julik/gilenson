# -*- encoding: utf-8 -*- 
begin
  require 'redcloth'
  raise LoadError, "Need RedCloth 3.x to run this test" unless RedCloth::VERSION.to_s =~ /^3/

  # Интеграция с RedCloth - Textile.
  # Нужно иметь в виду что Textile осуществляет свою обработку типографики, которую мы подменяем!
  class Redcloth3IntegrationTest < Test::Unit::TestCase
    C = Gilenson::RedClothExtra
    def test_integration_with_redcloth_3
    
      assert_equal "<p>И&#160;вот &#171;они пошли туда&#187;, и&#160;шли шли&#160;шли</p>", 
        C.new('И вот "они пошли туда", и шли шли шли').to_html
    
      assert_equal '<p><strong>strong text</strong> and <em>emphasized text</em></p>',
        C.new("*strong text* and _emphasized text_").to_html,
          "Spaces should be preserved"
    end
  end
rescue LoadError => boom
  STDERR.puts(boom.message)
end