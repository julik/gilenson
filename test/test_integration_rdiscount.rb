# -*- encoding: utf-8 -*- 
begin
  require 'rdiscount'
  
  # Интеграция с Rdiscount - Markdown
  # Сам Markdown никакой обработки типографики не производит (это делает RubyPants, но вряд ли его кто-то юзает на практике)
  class RdiscountIntegrationTest < Test::Unit::TestCase
    C = ::Gilenson::RDiscountExtra
  
    def test_integration_markdown
    
      assert_equal "<p>И вот&#160;&#171;они пошли туда&#187;, и&#160;шли шли&#160;шли</p>", 
        C.new('И вот "они пошли туда", и шли шли шли').to_html
    end
  end
rescue LoadError, NameError => boom
  $stderr.puts("COULD NOT RUN INTEGRATION TEST: #{boom.message}")
end