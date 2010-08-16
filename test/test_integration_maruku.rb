# -*- encoding: utf-8 -*- 
begin
  require 'maruku'
  
  # Интеграция с Maruku - Markdown
  class MarukuIntegrationTest < Test::Unit::TestCase
    C = Gilenson::MarukuExtra
  
    def test_integration_maruku
    
      assert_equal "<p>И вот&#160;&#171;они пошли туда&#187;, и&#160;шли шли&#160;шли</p>", 
        C.new('И вот "они пошли туда", и шли шли шли').to_html
    
    end
  end
rescue LoadError => boom
  STDERR.puts(boom.message)
end