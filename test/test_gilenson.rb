# -*- encoding: utf-8 -*- 
$KCODE = 'u' if RUBY_VERSION < '1.9.0'
require 'test/unit'

# Prepend a slash to workaround a debilifuckitation (domo arigato Ruby core!)
require "./" + File.dirname(__FILE__) + '/../lib/gilenson'


# Cюда идут наши тесты типографа. Мы содержим их отдельно поскольку набор тестов Типографицы нами не контролируется.
# Когда у рутилей появятся собственные баги под каждый баг следует завести тест
class GilensonOwnTest < Test::Unit::TestCase
  
  def setup
    @gilenson = Gilenson.new
  end

  def test_tag_lift
    assert_equal "Вот&#160;такие<tag some='foo>' />  <tagmore></tagmore> дела", "Вот такие<tag some='foo>' />  <tagmore></tagmore> дела".gilensize
  end
  
  def test_byte_pass
    assert_equal '<p>Теперь добираться до офиса Студии автортранспортом стало удобнее. ' +
                  'Для этого мы разместили в разделе <a href="#">«Контакт»</a> окно вебкамеры, ' +
                  'которая непрерывно транслирует дорожную обстановку на Садовом кольце по адресу Земляной Вал, 23. <br>' +
                  'Удачной дороги! </p>',
                  '<p>Теперь добираться до офиса Студии автортранспортом стало удобнее. ' +
                  'Для этого мы разместили в разделе <a href="#">«Контакт»</a> окно вебкамеры, ' +
                  'которая непрерывно транслирует дорожную обстановку на Садовом кольце по адресу Земляной Вал, 23. <br>' +
                  'Удачной дороги! </p>'.gilensize
  end

  def test_phones
    assert_equal '<span class="nobr">3&#8211;12&#8211;30</span>', '3-12-30'.gilensize
    assert_equal '<span class="nobr">12&#8211;34&#8211;56</span>', '12-34-56'.gilensize
    assert_equal '<span class="nobr">88&#8211;25&#8211;04</span>', '88-25-04'.gilensize
    assert_equal '+7 <span class="nobr">(99284)&#160;65&#8211;818</span>', '+7 (99284) 65-818'.gilensize
    assert_equal '<span class="nobr">725&#8211;01&#8211;10</span>', '725-01-10'.gilensize
  end

  def test_acronyms_with_html_output
    assert_equal '<acronym title="Большая советская энциклопедия">БСЭ</acronym>', 'БСЭ(Большая советская энциклопедия)'.gilensize
    assert_equal '<acronym title="Advanced Micro Devices">AMD</acronym>',
      'AMD(Advanced Micro Devices)'.gilensize
    assert_equal '<acronym title="Расширяемый язык разметки">XML</acronym>',
      'XML(Расширяемый язык разметки)'.gilensize
  end

  def test_acronyms_should_escape_entities
    @gilenson.configure(:raw_output => false)
    assert_equal '<acronym title="Знак &#60;">БВГ</acronym>', 'БВГ(Знак <)'.gilensize
  end
  
  def test_acronyms_with_text_output
    @gilenson.configure(:raw_output => true)
    thin_space = [8201].pack("U")
    assert_equal_cp "так утверждает БСЭ#{thin_space}(Большая советская энциклопедия)",
      @gilenson.process('так утверждает БСЭ(Большая советская энциклопедия)')
  end
  
  def test_address  
    assert_equal 'табл.&#160;2, рис.&#160;2.10', 'табл. 2, рис. 2.10'.gilensize
    assert_equal 'офис&#160;415, оф.340, д.5, ул.&#160;Народной Воли, пл. Малышева', 'офис 415, оф.340, д.5, ул. Народной Воли, пл. Малышева'.gilensize
  end

  def test_html_entities_replace
    assert_equal '&#34; &#38; &#39; &#62; &#60; &#160; &#167; &#169; &#171; &#174; &#176; &#177; &#183; &#187; &#8211; &#8212; &#8216; &#8217; &#8220; &#8221; &#8222; &#8226; &#8230; &#8482; &#8722;', '&quot; &amp; &apos; &gt; &lt; &nbsp; &sect; &copy; &laquo; &reg; &deg; &plusmn; &middot; &raquo; &ndash; &mdash; &lsquo; &rsquo; &ldquo; &rdquo; &bdquo; &bull; &hellip; &trade; &minus;'.gilensize
  end

  def test_non_displayable_entities_replace1 # not_correct_number
    assert_equal '&#8222; &#8230; &#39; &#8220; &#8221; &#8226; &#8211; &#8212; &#8482;', '&#132; &#133; &#146; &#147; &#148; &#149; &#150; &#151; &#153;'.gilensize
  end
  
  def test_non_displayable_entities_replace2 # copy&paste
    @gilenson.configure!(:copypaste => true)
    assert_equal '&#171; &#160; &#187; &#167; &#169; &#174; &#176; &#177; &#182; &#183; &#8211; &#8212; &#8216; &#8217; &#8220; &#8221; &#8222; &#8226; &#8230; &#8470; &#8482; &#8722; &#8201; &#8243;', @gilenson.process('«   » § © ® ° ± ¶ · – — ‘ ’ “ ” „ • … № ™ −   ″')
  end

  def test_nbsp_removed_on_anchor_start
    assert_equal 'abcd', @gilenson.process(' abcd')
  end

  def test_nbsp_removed_on_anchor_end
    assert_equal 'abcd', @gilenson.process('abcd ')
  end
  
  def test_specials
    assert_equal '&#169; 2002, &#169; 2003, &#169; 2004, &#169; 2005 &#8212; тоже без&#160;пробелов: &#169;2002, &#169;Кукуц. однако: варианты (а) и&#160;(с)', '(с) 2002, (С) 2003, (c) 2004, (C) 2005 -- тоже без пробелов: (с)2002, (c)Кукуц. однако: варианты (а) и (с)'.gilensize
    assert_equal '+5&#176;С, +7&#176;C, &#8211;5&#176;F', '+5^С, +17^C, -275^F'.gilensize
    assert_equal 'об&#160;этом подробнее &#8212; читай &#167;25', 'об этом подробнее -- читай (p)25'.gilensize
    assert_equal 'один же&#160;минус &#8211; краткое тире', 'один же минус - краткое тире'.gilensize
    assert_equal 'Sharpdesign&#8482;, Microsoft<sup>&#174;</sup>', 'Sharpdesign(tm), Microsoft(r)'.gilensize
  end

  def test_breaking
    assert_equal 'скажи, мне, ведь не&#160;даром! Москва, клеймённая пожаром. Французу отдана', 'скажи ,мне, ведь не даром !Москва, клеймённая пожаром .Французу отдана'.gilensize
    assert_equal 'so&#160;be it, my&#160;liege. Tiny dwellers roam thru midnight! Hell raised, the&#160;Balrog is&#160;hiding in&#160;your backyard!', 'so be it ,my liege .Tiny dwellers roam thru midnight !Hell raised, the Balrog is hiding in your backyard!'.gilensize
    assert_equal 'при&#160;установке командой строки в&#160;?page=help <span class="nobr">бла-бла-бла-бла</span>', 'при установке командой строки в ?page=help бла-бла-бла-бла'.gilensize
    assert_equal 'как&#160;интересно будет переноситься со&#160;строки на&#160;строку <span class="nobr">что-то</span> разделённое дефисом, ведь дефис тот&#160;тоже ведь из&#160;наших. <span class="nobr">Какие-то</span> браузеры думают, что&#160;следует переносить и&#160;его&#8230;', 'как интересно будет переноситься со строки на строку что-то разделённое дефисом, ведь дефис тот тоже ведь из наших. Какие-то браузеры думают, что следует переносить и его...'.gilensize
  end
  
  def test_forced_quotes
    assert_equal 'кавычки &#171;расставлены&#187; &#8220;in a&#160;chaotic order&#8221;',
      'кавычки "расставлены" "in a chaotic order"'.gilensize
    assert_equal 'кавычки &#8220;расставлены&#8221; &#8220;in a&#160;chaotic order&#8221;', 
      'кавычки "расставлены" "in a chaotic order"'.gilensize(:enforce_en_quotes => true)
    assert_equal 'кавычки &#171;расставлены&#187; &#171;in a&#160;chaotic order&#187;', 
      'кавычки "расставлены" "in a chaotic order"'.gilensize(:enforce_ru_quotes => true)
  end
  
#def test_quotes_and_inch
#  assert_equal "&#171;This one&#160;is&#160;12&#8342;&#187;", '"This one is 12""'.gilensize
#end
  
  def test_quotes  
    assert_equal 'english &#8220;quotes&#8221; should be&#160;quite like this', 'english "quotes" should be quite like this'.gilensize
    assert_equal 'русские же&#160;&#171;оформляются&#187; подобным образом', 'русские же "оформляются" подобным образом'.gilensize
    assert_equal 'кавычки &#171;расставлены&#187; &#8220;in a&#160;chaotic order&#8221;', 'кавычки "расставлены" "in a chaotic order"'.gilensize
    assert_equal 'диагональ моего монитора &#8212; 17&#8243;, а&#160;размер пениса &#8212; 1,5&#8243;', 'диагональ моего монитора -- 17", а размер пениса -- 1,5"'.gilensize
    assert_equal 'в&#160;толщину, &#171;вложенные &#8220;quotes&#8221; вот&#160;так&#187;, &#8220;or it&#160;&#171;будет вложено&#187; elsewhere&#8221;', 'в толщину, "вложенные "quotes" вот так", "or it "будет вложено" elsewhere"'.gilensize
    assert_equal '&#8220;complicated &#171;кавычки&#187;, &#171;странные &#8220;includements&#8221; кавычек&#187;', '"complicated "кавычки", "странные "includements" кавычек"'.gilensize
    assert_equal '&#8220;double &#8220;quotes&#8221;', '"double "quotes"'.gilensize
    assert_equal '&#171;дважды вложенные &#171;кавычки&#187;', '"дважды вложенные "кавычки"'.gilensize
    assert_equal '&#171;01/02/03&#187;, дискеты в&#160;5.25&#8243;', '"01/02/03", дискеты в 5.25"'.gilensize
    assert_equal 'после троеточия правая кавычка &#8212; &#171;Вот&#8230;&#187;', 'после троеточия правая кавычка -- "Вот..."'.gilensize
    assert_equal 'setlocale(LC_ALL, &#8220;ru_RU.UTF8&#8221;);', 'setlocale(LC_ALL, "ru_RU.UTF8");'.gilensize
    assert_equal '&#8220;read, write, delete&#8221; с&#160;флагом &#8220;only_mine&#8221;', '"read, write, delete" с флагом "only_mine"'.gilensize
    assert_equal '&#171;Двоеточие:&#187;, &#171;такую умную тему должен писать чувак умеющий скрипты скриптить.&#187;', '"Двоеточие:", "такую умную тему должен писать чувак умеющий скрипты скриптить."'.gilensize
    assert_equal '(&#171;Вики != HTML&#187; &#8212; &#171;Вики != HTML&#187; &#8212; (&#171;всякая чушь&#187;))', '("Вики != HTML" -- "Вики != HTML" -- ("всякая чушь"))'.gilensize
    assert_equal '&#171;фигня123&#187;, &#8220;fignya123&#8221;', '"фигня123", "fignya123"'.gilensize
#      assert_equal '&#171;сбалансированные &#171;кавычки<!--notypo--><!--/notypo--> (четыре в&#160;конце) &#8212; связано с&#160;синтаксисом ваки', '"сбалансированные "кавычки"""" (четыре в конце) -- связано с синтаксисом ваки'.gilensize
    assert_equal '&#171;несбалансированные &#171;кавычки&#34;&#34;" (три в&#160;конце) &#8212; связано с&#160;синтаксисом ваки', '"несбалансированные "кавычки""" (три в конце) -- связано с синтаксисом ваки'.gilensize
    assert_equal '&#171;разноязыкие quotes&#187;', '"разноязыкие quotes"'.gilensize
    assert_equal '&#171;multilanguage кавычки&#187;', '"multilanguage кавычки"'.gilensize
  end

  def test_additional_quote_cases
    assert_equal  "&#171;И это&#160;называется языком?&#187;, &#8212; таков был&#160;его вопрос", 
                      %q{ "И это называется языком?", -- таков был его вопрос }.gilensize

    assert_equal  "&#171;Он &#8212; сволочь!&#187;, сказал&#160;я", 
                      %q{ "Он -- сволочь!", сказал я }.gilensize
  end

  def test_initials
    assert_equal 'Это&#160;нам сказал П.И.&#8201;Петров', 'Это нам сказал П. И. Петров'.gilensize

    assert_equal "А&#160;Ефимов&#8230;",
      @gilenson.process("А Ефимов...")

    assert_equal "Обратился за&#160;ПО. К&#160;негодяям.",
      @gilenson.process("Обратился за ПО. К негодяям.")

    assert_equal "ГО&#160;Самарской обл.",
      @gilenson.process("ГО Самарской обл.")

    assert_equal "ГОР&#160;Самарской обл.",
      @gilenson.process("ГОР Самарской обл.")
    
    assert_equal "КОШМАР Самарской обл.",
      @gilenson.process("КОШМАР Самарской обл.")
    
    assert_equal "УФПС Самарской обл.",
      @gilenson.process("УФПС Самарской обл.")

  end

  def test_nbsp_last_letters
    assert_equal  "сказал&#160;я", "сказал я".gilensize
    assert_equal  "сказал&#160;я!", "сказал я!".gilensize
    assert_equal  "сказал&#160;я?", "сказал я?".gilensize
    assert_equal  "сказал&#160;я&#8230;", "сказал я...".gilensize
    assert_equal  "сказал&#160;он&#8230;", "сказал он...".gilensize
    assert_equal  "сказали&#160;мы?..", "сказали мы?..".gilensize
    assert_equal  "сказали&#160;мы?!", "сказали мы?!".gilensize
    assert_equal  "сказали мы?!!!", "сказали мы?!!!".gilensize
    assert_equal  "сказали нам", "сказали нам".gilensize
    assert_equal  "(сказали&#160;им)", "(сказали им)".gilensize
    assert_equal  "Справка&#160;09", 'Справка 09'.gilensize
  end
  
  def test_wordglue_combined_with_glyphs # http://pixel-apes.com/typografica/trako/12
    assert_equal "&#171;Справка&#160;09&#187;", '"Справка 09"'.gilensize(:wordglue => true)
  end
  
  def test_marker_bypass
    assert_equal "<p><span class=\"nobr\">МИЭЛЬ-Недвижимость</span></p>", "<p>МИЭЛЬ-Недвижимость</p>".gilensize
  end
  
  def test_skip_code
    @gilenson.configure!(:all => true, :skip_code => true)
    
    assert_equal "<code>Скип -- скип!</code>",
      @gilenson.process("<code>Скип -- скип!</code>")
    
    assert_equal '<code attr="test -- attr">Скип -- скип!</code>',
      @gilenson.process('<code attr="test -- attr">Скип -- скип!</code>')
    
    assert_equal "<tt>Скип -- скип!</tt> test &#8212; test <tt attr='test -- attr'>Скип -- скип!</tt>",
      @gilenson.process("<tt>Скип -- скип!</tt> test -- test <tt attr='test -- attr'>Скип -- скип!</tt>")
    
    assert_equal "<tt>Скип -- скип!</tt><tt>Скип -- скип!</tt> &#8212; <code attr='test -- attr'>Скип -- скип!</code>",
      @gilenson.process("<tt>Скип -- скип!</tt><tt>Скип -- скип!</tt> -- <code attr='test -- attr'>Скип -- скип!</code>")
    
    assert_equal "<ttt>Скип &#8212; скип!</tt>",
      @gilenson.process("<ttt>Скип -- скип!</tt>")
    
    assert_equal "<tt>Скип &#8212; скип!</ttt>",
      @gilenson.process("<tt>Скип -- скип!</ttt>")
    
    assert_equal "Ах, &#8212; <code>var x = j // -- тест</code>",
      @gilenson.process("Ах, -- <code>var x = j // -- тест</code>")
    
    assert_equal "<![CDATA[ CDATA -- ]]> &#8212; CDATA",
      @gilenson.process("<![CDATA[ CDATA -- ]]> -- CDATA")
    
    assert_equal "<![CDATA[ CDATA -- >] -- CDATA ]]> &#8212; <![CDATA[ CDATA ]> -- CDATA ]]>",
      @gilenson.process("<![CDATA[ CDATA -- >] -- CDATA ]]> -- <![CDATA[ CDATA ]> -- CDATA ]]>")
    
    assert_equal "<![CDATA[ CDATA -- >] -- CDATA ]]> &#8212; <![CDATA[ CDATA ]> -- CDATA ]]>  &#8212; CDATA ]]>",
      @gilenson.process("<![CDATA[ CDATA -- >] -- CDATA ]]> -- <![CDATA[ CDATA ]> -- CDATA ]]>  -- CDATA ]]>")
    
    @gilenson.configure!(:skip_code => false)
    
    assert_equal "Ах, &#8212; <code>var x&#160;= j&#160;// &#8212; тест</code>",
      @gilenson.process("Ах, -- <code>var x = j // -- тест</code>")
  end

  def test_skip_attr
    @gilenson.configure!(:skip_attr => true)
    
    assert_equal "<a href='#' attr='смотри -- смотри' title='test -- me' alt=\"смотри -- смотри\">just &#8212; test</a>",
      @gilenson.process("<a href='#' attr='смотри -- смотри' title='test -- me' alt=\"смотри -- смотри\">just -- test</a>")
    
    assert_equal 'мы&#160;напишем title="test &#8212; me" и&#160;alt=\'test &#8212; me\', вот',
      @gilenson.process('мы напишем title="test -- me" и alt=\'test -- me\', вот')
    
    @gilenson.configure!(:skip_attr => false)
    
    assert_equal "<a href='#' attr='смотри -- смотри' title='test &#8212;&#160;me' alt=\"смотри &#8212; смотри\">just &#8212; test</a>",
      @gilenson.process("<a href='#' attr='смотри -- смотри' title='test -- me' alt=\"смотри -- смотри\">just -- test</a>")
    
    assert_equal 'мы&#160;напишем title="test &#8212; me" и&#160;alt=\'test &#8212; me\', вот',
      @gilenson.process('мы напишем title="test -- me" и alt=\'test -- me\', вот')
  end
  
  def test_escape_html
    assert_equal "Используйте &#38; вместо &#38;amp;",
      @gilenson.process("Используйте &#38; вместо &#38;amp;")
    
    @gilenson.configure!(:html => false)
    
    assert_equal "&#38;#38; &#8212; &#38;amp; &#60;code/&#62; &#60;some_tag&#62;таги не&#160;пройдут!&#60;/some_tag&#62;. Ну&#160;и?..",
      @gilenson.process("&#38; -- &amp; <code/> <some_tag>таги не пройдут!</some_tag>. Ну и?..")
    
    assert_equal "Используйте &#38;#38; вместо &#38;amp;",
      @gilenson.process("Используйте &#38; вместо &amp;")
    
  end

  def test_ampersand_in_urls
    
    @gilenson.configure!(:html=>false)
    
    assert_equal "&#60;a href='test?test5=5&#38;#38;test6=6'&#62;test&#38;#38;&#60;/a&#62;",
      @gilenson.process("<a href='test?test5=5&#38;test6=6'>test&#38;</a>")
    
    @gilenson.configure!(:html=>true)
    
    assert_equal "<a href='test?test7=7&#38;test8=8'>test&#38;</a>",
      @gilenson.process("<a href='test?test7=7&#38;test8=8'>test&#38;</a>")
    
    assert_equal "<a href='test?test9=9&#038;test10=10'>test&#038;</a>",
      @gilenson.process("<a href='test?test9=9&#038;test10=10'>test&#038;</a>")
    
    assert_equal "<a href='test?test11=11&#38;test12=12'>test&</a>",
      @gilenson.process("<a href='test?test11=11&test12=12'>test&</a>")
    
    assert_equal "<a href='test?test12=12&#38;'>test</a>",
      @gilenson.process("<a href='test?test12=12&amp;'>test</a>")
    
    assert_equal "<a href='test?x=1&#38;y=2' title='&#38;-amp, &#8230;-hellip'>test</a>",
      @gilenson.process("<a href='test?x=1&y=2' title='&#38;-amp, &#8230;-hellip'>test</a>")
    
    assert_equal "<a href='test?x=3&#38;#039;y=4'>test</a>",
      @gilenson.process("<a href='test?x=3&#039;y=4'>test</a>")
    
    
    @gilenson.glyph[:amp] = '&amp;'
    
    assert_equal "<a href='test?test11=11&amp;test12=12'>test&</a>",
      @gilenson.process("<a href='test?test11=11&test12=12'>test&</a>")
    
    assert_equal "<a href='test?test13=13&amp;test14=14'>test&</a>",
      @gilenson.process("<a href='test?test13=13&amp;test14=14'>test&</a>")
    
    assert_equal "<a href='test?test15=15&amp;amppp;test16=16'>test&</a>",
      @gilenson.process("<a href='test?test15=15&amppp;test16=16'>test&</a>")
    
  end
  
  private
    # Проверить равны ли строки, и если нет то обьяснить какой кодпойнт отличается.
    # Совершенно необходимо для работы с различными пробелами.
    def assert_equal_cp(reference, actual, msg = nil)
      (assert(true, msg); return) if (reference == actual)
      
      reference_cp, actual_cp = [reference, actual].map{|t| t.unpack("U*") }
      reference_cp.each_with_index do | ref_codepoint, idx |
        next unless actual_cp[idx] != ref_codepoint
        beg, fin = idx - 2, idx + 2
        beg = 0 if (beg < 0)
        conflicting_piece = actual_cp[beg..fin].pack("U*")
        msg = []
        msg << "Expected #{actual.inspect} to be equal to #{reference.inspect}, but they were not, " +
               "in fragment '#{beg > 0 ? '...' : ''}#{conflicting_piece}...'"
        msg << "Non-matching codepoint #{actual[idx]} at offset #{idx}, " +
               "expected codepoint #{ref_codepoint} instead"
        flunk msg.join("\n"); return
      end
      raise "We should never get here"
    end
end


class GilensonConfigurationTest < Test::Unit::TestCase
  def setup
    @gilenson = Gilenson.new
  end
  
  def test_settings_as_tail_arguments

    assert_equal "Ну&#160;и куда вот&#160;&#8212; да&#160;туда!", 
      @gilenson.process("Ну и куда вот -- да туда!")

    assert_equal "Ну и куда вот &#8212; да туда!", 
      @gilenson.process("Ну и куда вот -- да туда!", :dash => false, :dashglue => false, :wordglue => false)

    assert_equal "Ну&#160;и куда вот&#160;&#8212; да&#160;туда!", 
      @gilenson.process("Ну и куда вот -- да туда!")
      
    @gilenson.configure!(:dash => false, :dashglue => false, :wordglue => false)

    assert_equal "Ну и куда вот &#8212; да туда!", 
      @gilenson.process("Ну и куда вот -- да туда!")    

    @gilenson.configure!(:all => true)

    assert_equal "Ну&#160;и куда вот&#160;&#8212; да&#160;туда!", 
      @gilenson.process("Ну и куда вот -- да туда!")

    @gilenson.configure!(:all => false)

    assert_equal "Ну и куда вот -- да туда!", 
      @gilenson.process("Ну и куда вот -- да туда!")
  end
  
  def test_glyph_override
    assert_equal 'скажи, мне, ведь не&#160;даром! Москва, клеймённая пожаром. Французу отдана',
      @gilenson.process('скажи ,мне, ведь не даром !Москва, клеймённая пожаром .Французу отдана')

    @gilenson.glyph[:nbsp] = '&nbsp;'
    assert_equal 'скажи, мне, ведь не&nbsp;даром! Москва, клеймённая пожаром. Французу отдана',
      @gilenson.process('скажи ,мне, ведь не даром !Москва, клеймённая пожаром .Французу отдана')
  end
  
  def test_raise_on_unknown_setting
    assert_raise(Gilenson::UnknownSetting) { @gilenson.configure!(:bararara => true) }
  end
  
  def test_raise_on_unknown_setting_via_gilensize
    assert_raise(Gilenson::UnknownSetting) { "s".gilensize(:bararara => true) }
  end
  
  def test_backslash_does_not_suppress_quote # http://pixel-apes.com/typografica/trako/13, но с латинскими кавычками
    assert_equal "&#8220;c:\\www\\sites\\&#8221;", '"c:\www\sites\"'.gilensize
  end
  
  def test_cpp
    assert_equal "C++-API", "C++-API".gilensize
  end
  
  def test_raw_utf8_output
    @gilenson.configure!(:raw_output=>true)
    assert_equal '&#38442; Это просто «кавычки»',
      @gilenson.process('&#38442; Это просто "кавычки"')    
  end
  
  def test_configure_alternate_names
    assert @gilenson.configure(:raw_output=>true)    
    assert @gilenson.configure!(:raw_output=>true)    
  end
  
  def test_explicit_nobr
    @gilenson.glyph[:nob_open] = '[NOB]'
    @gilenson.glyph[:nob_close] = '[NOBC]'
    assert_equal '[NOB]3&#8211;12&#8211;30[NOBC]', @gilenson.process('3-12-30')
  end
end