class Config
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

  SKIP_CODE_TAGS = ["code", "tt"]

  def initialize(config = {})
    accept_configuration_arguments!(config)

    @ignore = /notypo/ # regex, который игнорируется. Этим надо воспользоваться для обработки pre и code

    @glueleft =  ['рис.', 'табл.', 'см.', 'им.', 'ул.', 'пер.', 'кв.', 'офис', 'оф.', 'г.']
    @glueright = ['руб.', 'коп.', 'у.е.', 'мин.']

    @mark_tag = REPLACEMENT_MARKER

    @settings = SETTINGS.dup

    # Глифы можено подменять в экземпляре форматтера поэтому копируем их из константы
    @glyph = GLYPHS.dup

    @phonemasks = [
      [
        /([0-9]{4})\-([0-9]{2})\-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/,
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
      ]
    ]
  end

  # Настраивает форматтер ассоциированным хешем
  #  formatter.configure!(:dash=>true, :wordglue=>false)
  def configure!(*config)
    accept_configuration_arguments!(config.last) if config.last.is_a?(Hash)
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

  alias :configure :configure! #Дружественный API

  # Неизвестные методы - настройки. С = - установка ключа, без - получение значения
  def method_missing(meth, *args) #:nodoc:
    setting = meth.to_s.gsub(/=$/, '')
    super(meth, *args) unless @settings.has_key?(setting) #this will pop the exception if we have no such setting

    return (@settings[setting] = args[0])
  end
end