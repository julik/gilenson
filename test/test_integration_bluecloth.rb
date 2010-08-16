# -*- encoding: utf-8 -*- 
begin
  require 'bluecloth'

  # Интеграция с BlueCloth - Markdown
  # Сам Markdown никакой обработки типографики не производит (это делает RubyPants, но вряд ли его кто-то юзает на практике)
  class BlueclothIntegrationTest < Test::Unit::TestCase
    C = Gilenson::BlueClothExtra
  
    def test_integration_markdown
      assert_equal "<p>И вот&#160;&#171;они пошли туда&#187;, и&#160;шли шли&#160;шли</p>", 
        C.new('И вот "они пошли туда", и шли шли шли').to_html
    end
  end
rescue LoadError => boom
  STDERR.puts(boom.message)
end