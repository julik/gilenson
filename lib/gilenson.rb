# -*- encoding: utf-8 -*-
if RUBY_VERSION < '1.9.0'
  old_kcode = $KCODE
  $KCODE = 'u'
end

class Gilenson
  attr_accessor :glyph
  attr_accessor :settings

  # Выбрасывается если форматтеру задается неизвестная настройка
  class Gilenson::UnknownSetting < RuntimeError
  end

  SETTINGS = {
     "inches"    => true,    # преобразовывать дюймы в знак дюйма;
     "laquo"     => true,    # кавычки-ёлочки
     "quotes"    => true,    # кавычки-английские лапки
     "dash"      => true,    # короткое тире (150)
     "emdash"    => true,    # длинное тире двумя минусами (151)
     "initials"  => true,    # тонкие шпации в инициалах
     "copypaste" => false,   # замена непечатных и "специальных" юникодных символов на entities
     "(c)" => true,    # обрабатывать знаки копирайтов и трейдмарков
     "acronyms"  => true,    # Акронимы с пояснениями - ЖЗЛ(Жизнь Замечатльных Людей)
     "+-"        => true,    # спецсимволы, какие - понятно
     "degrees"   => true,    # знак градуса
     "dashglue"  => true, "wordglue" => true, # приклеивание предлогов и дефисов
     "spacing"   => true,    # запятые и пробелы, перестановка
     "phones"    => true,    # обработка телефонов
     "html"      => true,    # разрешение использования тагов html
     "raw_output" => false,  # выводить UTF-8 вместо entities
     "skip_attr" => false,   # при true не отрабатывать типографику в атрибутах тегов
     "skip_code" => true,    # при true не отрабатывать типографику внутри <code/>, <tt/>, CDATA
     "enforce_en_quotes" => false, # только латинские кавычки
     "enforce_ru_quotes" => false, # только русские кавычки (enforce_en_quotes при этом игнорируется)
     "(r)"       => true, # DEPRECATED
     "(tm)"      => true, # DEPRECATED
     "(p)"       => true, # DEPRECATED
  }.freeze

  #:stopdoc:
  # Старые настройки которые больше не нужны - уйдут в следующей большой версии
  # Нужны потому иначе будет брошена ошибка
  #:startdoc:

  # Глифы, использующиеся в подстановках по-умолчанию
  GLYPHS = {
    :quot       => "&#34;",     # quotation mark
    :amp        => "&#38;",     # ampersand
    :apos       => "&#39;",     # apos
    :gt         => "&#62;",     # greater-than sign
    :lt         => "&#60;",     # less-than sign
    :nbsp       => "&#160;",    # non-breaking space
    :sect       => "&#167;",    # section sign
    :copy       => "&#169;",    # copyright sign
    :laquo      => "&#171;",    # left-pointing double angle quotation mark = left pointing guillemet
    :reg        => "&#174;",    # registered sign = registered trade mark sign
    :deg        => "&#176;",    # degree sign
    :plusmn     => "&#177;",    # plus-minus sign = plus-or-minus sign
    :para       => "&#182;",    # pilcrow sign = paragraph sign
    :middot     => "&#183;",    # middle dot = Georgian comma = Greek middle dot
    :raquo      => "&#187;",    # right-pointing double angle quotation mark = right pointing guillemet
    :ndash      => "&#8211;",   # en dash
    :mdash      => "&#8212;",   # em dash
    :lsquo      => "&#8216;",   # left single quotation mark
    :rsquo      => "&#8217;",   # right single quotation mark
    :ldquo      => "&#8220;",   # left double quotation mark
    :rdquo      => "&#8221;",   # right double quotation mark
    :bdquo      => "&#8222;",   # double low-9 quotation mark
    :bull       => "&#8226;",   # bullet = black small circle
    :hellip     => "&#8230;",   # horizontal ellipsis = three dot leader
    :numero     => "&#8470;",   # numero
    :trade      => "&#8482;",   # trade mark sign
    :minus      => "&#8722;",   # minus sign
    :inch       => "&#8243;",   # inch/second sign (u0x2033) (не путать с кавычками!)
    :thinsp     => "&#8201;",   # полукруглая шпация (тонкий пробел)
    :nob_open   => '<span class="nobr">',    # открывающий блок без переноса слов
    :nob_close  => '</span>',    # закрывающий блок без переноса слов
  }.freeze

  # Нормальные "типографские" символы в UTF-виде. Браузерами обрабатываются плохонько, поэтому
  # лучше заменять их на entities.
  VERBATIM_GLYPHS = {
    ' '         => :nbsp,# alt+0160 (NBSP here)
    '«'         => :laquo,
    '»'         => :raquo,
    '§'         => :sect,
    '©'         => :copy,
    '®'         => :reg,
    '°'         => :deg,
    '±'         => :plusmn,
    '¶'         => :para,
    '·'         => :middot,
    '–'         => :ndash,
    '—'         => :mdash,
    '‘'         => :lsquo,
    '’'         => :rsquo,
    '“'         => :ldquo,
    '”'         => :rdquo,
    '„'         => :bdquo,
    '•'         => :bull,
    '…'         => :hellip,
    '№'         => :numero,
    '™'         => :trade,
    '−'         => :minus,
    ' '         => :thinsp,
    '″'         => :inch,
   }.freeze

   # Метка на которую подменяются вынутые теги  - Unicode Character 'OBJECT REPLACEMENT CHARACTER' (U+FFFC)
   # http://unicode.org/reports/tr20/tr20-1.html
   # Он официально применяется для обозначения вложенного обьекта
   REPLACEMENT_MARKER = [0xEF, 0xBF, 0xBC].pack("U*").freeze

   # Кто придумал &#147;? Не учите людей плохому...
   # Привет А.Лебедеву http://www.artlebedev.ru/kovodstvo/62/
   # Используем символы, потом берем по символам из glyphs форматтера.
   # Молодец mash!
   FORBIDDEN_NUMERIC_ENTITIES = {
     '132'       => :bdquo,
     '133'       => :hellip,
     '146'       => :apos,
     '147'       => :ldquo,
     '148'       => :rdquo,
     '149'       => :bull,
     '150'       => :ndash,
     '151'       => :mdash,
     '153'       => :trade,
   }.freeze

   # Все юникодные пробелы, шпации и отступы
   UNICODE_WHITESPACE = [
     (0x0009..0x000D).to_a, # White_Space # Cc   [5] <control-0009>..<control-000D>
     0x0020,                # White_Space # Zs       SPACE
     0x0085,                # White_Space # Cc       <control-0085>
     0x00A0,                # White_Space # Zs       NO-BREAK SPACE
     0x1680,                # White_Space # Zs       OGHAM SPACE MARK
     0x180E,                # White_Space # Zs       MONGOLIAN VOWEL SEPARATOR
     (0x2000..0x200A).to_a, # White_Space # Zs  [11] EN QUAD..HAIR SPACE
     0x2028,                # White_Space # Zl       LINE SEPARATOR
     0x2029,                # White_Space # Zp       PARAGRAPH SEPARATOR
     0x202F,                # White_Space # Zs       NARROW NO-BREAK SPACE
     0x205F,                # White_Space # Zs       MEDIUM MATHEMATICAL SPACE
     0x3000,                # White_Space # Zs       IDEOGRAPHIC SPACE
   ].flatten.pack("U*").freeze

   PROTECTED_SETTINGS = [ :raw_output ] #:nodoc:

   def initialize(*args)
     @_text = args[0].is_a?(String) ? args[0] : ''
     setup_default_settings!
     accept_configuration_arguments!(args.last) if args.last.is_a?(Hash)
   end

   # Настраивает форматтер ассоциированным хешем
   #  formatter.configure!(:dash=>true, :wordglue=>false)
   def configure!(*config)
     accept_configuration_arguments!(config.last) if config.last.is_a?(Hash)
   end

   alias :configure :configure! #Дружественный API

   # Неизвестные методы - настройки. С = - установка ключа, без - получение значения
   def method_missing(meth, *args) #:nodoc:
     setting = meth.to_s.gsub(/=$/, '')
     super(meth, *args) unless @settings.has_key?(setting) #this will pop the exception if we have no such setting

     return (@settings[setting] = args[0])
   end

   # Обрабатывает text_to_process с сохранением настроек, присвоенных обьекту-форматтеру
   # Дополнительные аргументы передаются как параметры форматтера и не сохраняются после прогона.
   def process(text_to_process, *args)
     @_text = text_to_process

     args.last.is_a?(Hash) ? with_configuration(args.last) { to_html } : to_html
   end

   # Обрабатывает текст, присвоенный форматтеру при создании и возвращает результат обработки
   def to_html
     return '' unless @_text

     # NOTE: strip is Unicode-space aware on 1.9.1, so here we simulate that
     text = @_text.gsub(/[#{UNICODE_WHITESPACE}]\z/, '').gsub(/\A[#{UNICODE_WHITESPACE}]/, '')

     # -6. Подмухляем таблицу глифов, если нам ее передали
     glyph_table = glyph.dup

     if @settings["enforce_ru_quotes"]
       glyph_table[:ldquo], glyph_table[:rdquo] = glyph_table[:laquo], glyph_table[:raquo]
     elsif @settings["enforce_en_quotes"]
       glyph_table[:laquo], glyph_table[:raquo] = glyph_table[:ldquo], glyph_table[:rdquo]
     end

     # -5. Копируем глифы в ивары, к ним доступ быстр и в коде они глаза тоже не мозолят
     glyph_table.each_pair do | ki, wi |
       instance_variable_set("@#{ki}", wi)
     end

     # -4. запрет тагов html
     process_escape_html(text) unless @settings["html"]

     # -3. Никогда (вы слышите?!) не пущать лабуду &#not_correct_number;
     FORBIDDEN_NUMERIC_ENTITIES.dup.each_pair do | key, rep |
       text.gsub!(/&##{key};/, self.glyph[rep])
     end

     # -2. Чистим copy&paste
     process_copy_paste_clearing(text) if @settings['copypaste']

     # -1. Замена &entity_name; на входе ('&nbsp;' => '&#160;' и т.д.)
     process_html_entities(text)

     # 0. Вырезаем таги
     tags = lift_ignored_elements(text) if @skip_tags

     # 1. Запятые и пробелы
     process_spacing(text) if @settings["spacing"]

     # 1. лапки
     process_quotes(text) if @settings["quotes"]

     # 2. ёлочки
     process_laquo(text) if @settings["laquo"]

     # 3. Инчи
     process_inches(text) if @settings["inches"]

     # 2b. одновременно ёлочки и лапки
     process_compound_quotes(text) if (@settings["quotes"] && @settings["laquo"])

     # 3. тире
     process_dash(text) if @settings["dash"]

     # 3a. тире длинное
     process_emdash(text) if @settings["emdash"]

     # 4. копимарки и трейдрайты
     process_copymarks(text) if @settings["(c)"]

     # 5. +/-
     process_plusmin(text) if @settings["+-"]

     # 5a. 12^C
     process_degrees(text) if @settings["degrees"]

     # 6. телефоны
     process_phones(text) if @settings["phones"]

     # 7. Короткие слова и &nbsp;
     process_wordglue(text) if @settings["wordglue"]

     # 8. Склейка ласт. Тьфу! дефисов.
     process_dashglue(text) if @settings["dashglue"]

     # 8a. Инициалы
     process_initials(text) if @settings['initials']

     # 8b. Троеточия
     process_ellipsises(text) if @settings["wordglue"]

     # 9. Акронимы от Текстиля
     process_acronyms(text) if @settings["acronyms"]

     # БЕСКОНЕЧНОСТЬ. Вставляем таги обратно.
     reinsert_fragments(text, tags) if @skip_tags

     # заменяем entities на истинные символы
     process_raw_output(text) if @settings["raw_output"]

     text.strip
   end


   # Применяет отдельный фильтр к text и возвращает результат. Например:
   #  formatter.apply(:wordglue, "Вот так") => "Вот&#160;так"
   # Удобно применять когда вам нужно задействовать отдельный фильтр Гиленсона, но не нужна остальная механика
   # Последний аргумент определяет, нужно ли при применении фильтра сохранить в неприкосновенности таги и другие
   # игнорируемые фрагменты текста (по умолчанию они сохраняются).
   def apply(filter, text, lift_ignored_elements = true)
     copy = text.dup
     unless lift_ignored_elements
       self.send("process_#{filter}".to_sym, copy)
     else
       lifting_fragments(copy) { self.send("process_#{filter}".to_sym, copy) }
     end
     copy
   end

   private

   def setup_default_settings!
      @skip_tags = true;
      @ignore = /notypo/ # regex, который игнорируется. Этим надо воспользоваться для обработки pre и code

      @glueleft =  ['рис.', 'табл.', 'см.', 'им.', 'ул.', 'пер.', 'кв.', 'офис', 'оф.', 'г.']
      @glueright = ['руб.', 'коп.', 'у.е.', 'мин.']

      # Установки можно менять в каждом экземпляре
      @settings = SETTINGS.dup

      @mark_tag = REPLACEMENT_MARKER
      # Глифы можено подменять в экземпляре форматтера поэтому копируем их из константы
      @glyph = GLYPHS.dup

      @phonemasks = [[  /([0-9]{4})\-([0-9]{2})\-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/,
                        /([0-9]{4})\-([0-9]{2})\-([0-9]{2})/,
                        /(\([0-9\+\-]+\)) ?([0-9]{3})\-([0-9]{2})\-([0-9]{2})/,
                        /(\([0-9\+\-]+\)) ?([0-9]{2})\-([0-9]{2})\-([0-9]{2})/,
                        /(\([0-9\+\-]+\)) ?([0-9]{3})\-([0-9]{2})/,
                        /(\([0-9\+\-]+\)) ?([0-9]{2})\-([0-9]{3})/,
                        /([0-9]{3})\-([0-9]{2})\-([0-9]{2})/,
                        /([0-9]{2})\-([0-9]{2})\-([0-9]{2})/,
                        /([0-9]{1})\-([0-9]{2})\-([0-9]{2})/,
                        /([0-9]{2})\-([0-9]{3})/,
                        /([0-9]+)\-([0-9]+)/,
                      ],[
                       ':nob_open\1:ndash\2:ndash\3:nbsp\4:\5:\6:nob_close',
                       ':nob_open\1:ndash\2:ndash\3:nob_close',
                       ':nob_open\1:nbsp\2:ndash\3:ndash\4:nob_close',
                       ':nob_open\1:nbsp\2:ndash\3:ndash\4:nob_close',
                       ':nob_open\1:nbsp\2:ndash\3:nob_close',
                       ':nob_open\1:nbsp\2:ndash\3:nob_close',
                       ':nob_open\1:ndash\2:ndash\3:nob_close',
                       ':nob_open\1:ndash\2:ndash\3:nob_close',
                       ':nob_open\1:ndash\2:ndash\3:nob_close',
                       ':nob_open\1:ndash\2:nob_close',
                       ':nob_open\1:ndash\2:nob_close'
                    ]]
   end

   # Позволяет получить процедуру, при вызове возвращающую значение глифа
#   def lookup(glyph_to_lookup)
#     return Proc.new { g[glyph_to_lookup] }
#   end

   # Подставляет "символы" (двоеточие + имя глифа) на нужное значение глифа заданное в данном форматтере
   def substitute_glyphs_in_string(str)
     re = str.dup
     @glyph.each_pair do | key, subst |
       re.gsub!(":#{key.to_s}", subst)
     end
     re
   end

   # Выполняет блок, временно включая настройки переданные в +hash+
   def with_configuration(hash, &block)
     old_settings, old_glyphs = @settings.dup, @glyph.dup
     accept_configuration_arguments!(hash)
       txt = yield
     @settings, @glyph = old_settings, old_glyphs

     return txt
   end

   def accept_configuration_arguments!(args_hash)

     # Специальный случай - :all=>true|false
     if args_hash.has_key?(:all)
       if args_hash[:all]
         @settings.each_pair {|k, v| @settings[k] = true unless PROTECTED_SETTINGS.include?(k.to_sym)}
       else
         @settings.each_pair {|k, v| @settings[k] = false unless PROTECTED_SETTINGS.include?(k.to_sym)}
       end
     else

       # Кинуть ошибку если настройка нам неизвестна
       unknown_settings = args_hash.keys.collect{|k|k.to_s} - @settings.keys.collect { |k| k.to_s }
       raise UnknownSetting, unknown_settings if unknown_settings.any?

       args_hash.each_pair do | key, value |
         @settings[key.to_s] = (value ? true : false)
       end
     end
   end

   # Вынимает игнорируемые фрагменты и заменяет их маркером, выполняет переданный блок и вставляет вынутое на место
   def lifting_fragments(text, &block)
     lifted = lift_ignored_elements(text)
       yield
     reinsert_fragments(text, lifted)
   end

   #Вынимает фрагменты из текста и возвращает массив с фрагментами
   def lift_ignored_elements(text)
    #     re =  /<\/?[a-z0-9]+("+ # имя тага
     #                              "\s+("+ # повторяющая конструкция: хотя бы один разделитель и тельце
     #                                     "[a-z]+("+ # атрибут из букв, за которым может стоять знак равенства и потом
     #                                              "=((\'[^\']*\')|(\"[^\"]*\")|([0-9@\-_a-z:\/?&=\.]+))"+ #
     #                                           ")?"+
     #                                  ")?"+
     #                            ")*\/?>|\xA2\xA2[^\n]*?==/i;

     re_skipcode = '((<(code|tt)[ >](.*?)<\/(code|tt)>)|(<!\[CDATA\[(.*?)\]\]>))|' if @settings['skip_code']
     re =  /(#{re_skipcode}<\/?[a-z0-9]+(\s+([a-z]+(=((\'[^\']*\')|(\"[^\"]*\")|([0-9@\-_a-z:\/?&=\.]+)))?)?)*\/?>)/uim
     tags = text.scan(re).map{ |tag| tag[0] } # первая группа!
     text.gsub!(re, @mark_tag) #маркер тега, мы используем Invalid UTF-sequence для него
     return tags
   end

   def reinsert_fragments(text, fragments)
     fragments.each do |fragment|
       fragment.gsub!(/ (href|src|data)=((?:(\')([^\']*)(\'))|(?:(\")([^\"]*)(\")))/uim) do
         " #{$1}=" + $2.gsub(/&(?!(#0*38)|(amp);)/, @amp)
       end # unless @settings['raw_output'] -- делать это надо всегда (mash)

       unless @settings['skip_attr']
         fragment.gsub!(/ (title|alt)=((?:(\')([^\']*)(\'))|(?:(\")([^\"]*)(\")))/uim) do
           " #{$1}=#{$3}" + self.process($4.to_s) + "#{$5}#{$6}" + self.process($7.to_s) + "#{$8}"
         end
       end
       text.sub!(@mark_tag, fragment)
     end
   end

   ### Имплементации фильтров
   def process_html_entities(text)
     self.glyph.each { |key, value| text.gsub!(/&#{key};/, value)}
   end

   def process_initials(text)
     initials = /([А-Я])[\.]{1,2}[\s]*?([А-Я])[\.]*[\s]*?([А-Я])([а-я])/u
     replacement = substitute_glyphs_in_string('\1.\2.:thinsp\3\4')
     text.gsub!(initials, replacement)
   end

   def process_copy_paste_clearing(text)
     VERBATIM_GLYPHS.each {|key,value| text.gsub!(/#{Regexp.escape(key)}/, glyph[value]) }
   end

   def process_spacing(text)
     text.gsub!( /(\s*)([,]*)/sui, '\2\1');
     text.gsub!( /(\s*)([\.?!]*)(\s*[ЁА-ЯA-Z])/su, '\2\1\3');
   end

   def process_dashglue(text)
     text.gsub!( /([a-zа-яА-Я0-9]+(\-[a-zа-яА-Я0-9]+)+)/ui, @nob_open+'\1'+ @nob_close)
   end

   def process_escape_html(text)
     text.gsub!(/&/, @amp)
     text.gsub!(/</, @lt)
     text.gsub!(/>/, @gt)
   end

   def process_dash(text)
     text.gsub!( /(\s|;)\-(\s)/ui, '\1'+@ndash+'\2')
   end

   def process_emdash(text)
     text.gsub!( /(\s|;)\-\-(\s)/ui, '\1'+@mdash+'\2')
   end

   def process_copymarks(text)
     # 4. (с)
     # Можно конечно может быть и так
     # https://github.com/daekrist/gilenson/commit/c3a96151239281dcef6140616133deb56a099d0f#L1R466
     # но без тестов это позорище.
     text.gsub!(/\([сСcC]\)[^\.\,\;\:]/ui) { |m| [@copy, m.split(//u)[-1..-1]].join }

     # 4a. (r)
     text.gsub!( /\(r\)/ui, '<sup>'+@reg+'</sup>')

     # 4b. (tm)
     text.gsub!( /\(tm\)|\(тм\)/ui, @trade)

     # 4c. (p)
     text.gsub!( /\(p\)/ui, @sect)
   end

   def process_ellipsises(text)
     text.gsub!( '...', @hellip)
   end

   def process_laquo(text)
     text.gsub!( /\"\"/ui, @quot * 2);
     text.gsub!( /(^|\s|#{@mark_tag}|>|\()\"((#{@mark_tag})*[~0-9ёЁA-Za-zА-Яа-я\-:\/\.])/ui, '\1' + @laquo + '\2');
     _text = '""';
     until _text == text do
       _text = text;
       text.gsub!( /(#{@laquo}([^\"]*)[ёЁA-Za-zА-Яа-я0-9\.\-:\/\?\!](#{@mark_tag})*)\"/sui, '\1' + @raquo)
     end
   end

   def process_quotes(text)
     text.gsub!( /\"\"/ui, @quot*2)
     text.gsub!( /\"\.\"/ui, @quot+"."+@quot)
     _text = '""';
     lat_c = '0-9A-Za-z'
     punct = /\'\!\s\.\?\,\-\&\;\:\\/

     until _text == text do
       _text = text.dup
       text.gsub!( /(^|\s|#{@mark_tag}|>)\"([#{lat_c}#{punct}\_\#{@mark_tag}]+(\"|#{@rdquo}))/ui, '\1'+ @ldquo +'\2')
       text.gsub!( /(#{@ldquo}([#{lat_c}#{punct}#{@mark_tag}\_]*).*[#{lat_c}][\#{@mark_tag}\?\.\!\,\\]*)\"/ui, '\1'+ @rdquo)
     end
   end

   def process_compound_quotes(text)
     text.gsub!(/(#{@ldquo}(([A-Za-z0-9'!\.?,\-&;:]|\s|#{@mark_tag})*)#{@laquo}(.*)#{@raquo})#{@raquo}/ui, '\1' + @rdquo);
   end

   def process_degrees(text)
     text.gsub!( /-([0-9])+\^([FCС])/, @ndash+'\1'+ @deg +'\2') #deg
     text.gsub!( /\+([0-9])+\^([FCС])/, '+\1'+ @deg +'\2')
     text.gsub!( /\^([FCС])/, @deg+'\1')
   end

   def process_wordglue(text)
     text.replace(" " + text + " ")
     _text = " " + text + " "

     until _text == text
        _text = text
        text.gsub!( /(\s+)([a-zа-яА-Я0-9]{1,2})(\s+)([^\\s$])/ui, '\1\2' + @nbsp +'\4')
        text.gsub!( /(\s+)([a-zа-яА-Я0-9]{3})(\s+)([^\\s$])/ui,   '\1\2' + @nbsp+'\4')
     end

     # Пунктуация это либо один из наших глифов, либо мемберы класса. В данном случае
     # мы цепляемся за кончик строки поэтому можум прихватить и глиф тоже
     # Пунктуация включает наши собственные глифы!
     punct = glyph.values.map{|v| Regexp.escape(v)}.join('|')
     vpunct = /(#{punct}|[\)\]\!\?,\.;])/

     text.gsub!(/(\s+)([a-zа-яА-Я0-9]{1,2}#{vpunct}{0,3}\s$)/ui, @nbsp+'\2')

     @glueleft.each { | i |  text.gsub!( /(\s)(#{i})(\s+)/sui, '\1\2' + @nbsp) }

     @glueright.each { | i | text.gsub!( /(\s)(#{i})(\s+)/sui, @nbsp+'\2\3') }

   end

   def process_phones(text)
      @phonemasks[0].each_with_index do |pattern, i|
        replacement = substitute_glyphs_in_string(@phonemasks[1][i])
        text.gsub!(pattern, replacement)
      end
   end

   def process_acronyms(text)
     acronym = /\b([A-ZА-Я][A-ZА-Я0-9]{2,})\b(?:[(]([^)]*)[)])/u
     if @settings["raw_output"]
       text.gsub!(acronym, '\1%s(\2)' % @thinsp)
     else
       text.gsub!(acronym) do
         expl = $2.to_s; process_escape_html(expl)
         "<acronym title=\"#{expl}\">#{$1}</acronym>"
       end
     end
   end

   # Обработка знака дюйма, кроме случаев когда он внутри кавычек
   def process_inches(text)
     text.gsub!(/\s([0-9]{1,2}([\.,][0-9]{1,2})?)(\"){1,1}/ui, ' \1' + @inch)
   end

   def process_plusmin(text)
     text.gsub!(/[^+]\+\-/ui, @plusmn)
   end

   # Подменяет все юникодные entities в тексте на истинные UTF-8-символы
   def process_raw_output(text)
     # Все глифы
     @glyph.values.each do | entity |
       next unless entity =~ /^&#(\d+);/
       text.gsub!(/#{entity}/, entity_to_raw_utf8(entity))
     end
   end

   # Конвертирует юникодные entities в UTF-8-codepoints
   def entity_to_raw_utf8(entity)
     entity =~ /^&#(\d+);/
     $1 ? [$1.to_i].pack("U") : entity
   end

   module StringFormatting
     # Форматирует строку с помощью Gilenson::Formatter. Все дополнительные опции передаются форматтеру.
     def gilensize(*args)
       ::Gilenson.new(self, args.shift || {}).to_html
     end
   end
end

Object::String.send(:include, Gilenson::StringFormatting)

$KCODE = old_kcode if RUBY_VERSION < '1.9.0'