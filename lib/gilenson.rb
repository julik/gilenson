# -*- encoding: utf-8 -*-
require "nokogiri"

class Gilenson
  attr_accessor :glyph
  attr_accessor :settings

  # Выбрасывается если форматтеру задается неизвестная настройка
  class Gilenson::UnknownSetting < RuntimeError
  end

  def initialize(text_to_process = '', *args)
    @_text = args.first.is_a?(String) ? args.first : ''

    # Если передан Hash, то используем его для создания нового экземпляра
    # конфигуратора
    # Если передан экземпляр конфигуратора, то используем его копию
    # Если передано что-то другое, используем конфиг по-умолчанию
    @config = case args.last
      when Hash
         ::Gilenson::Config.new(args.last)
       when ::Gilenson::Config
         args.last.dup
      else
        ::Gilenson::Config.new
    end
  end

  # Обрабатывает text_to_process с сохранением настроек, присвоенных обьекту-форматтеру
  # Дополнительные аргументы передаются как параметры форматтера и не сохраняются после прогона.
  def process(text_to_process, *args)
    @_text = text_to_process

    args.last.is_a?(Hash) ? with_configuration(args.last) { to_html } : to_html
  end

  # Обрабатывает текст, присвоенный форматтеру при создании и возвращает результат обработки
  def to_html
    return '' if @_text.nil?

    html = Nokogiri::HTML.fragment(@_text)

    process_children(html)

    html.to_html
  end

  # Рекурсивно проезжаемся по всему содержимому фрагмента, обрабатывая только текстовые
  # ноды.
  def process_children(node, process_node = true)
    process_node(node) if node.name == 'text'

    node.children.each do |node|
      process_children(node)
    end
  end

  # TODO: Компилировать метод на основании настроек, чтоб избежать проверок настроек для каждой ноды
  def process_node(node)
    # Пропускаем если выключена обработка кода
    if self.config['skip_code']
      return if SKIP_CODE_TAGS.include? node.parent.name
      return if node.cdata?
    end

    @current_node = node

    text = node.text

    text = text.gsub(/[#{UNICODE_WHITESPACE}]\z/, '').gsub(/\A[#{UNICODE_WHITESPACE}]/, '')

    # -4. запрет тагов html
    #process_escape_html(text) unless self.config["html"]

    # -3. Никогда (вы слышите?!) не пущать лабуду &#not_correct_number;
    process_fix_entities(text)

    # -2. Чистим copy&paste
    process_copy_paste_clearing(text) if self.config['copypaste']

    # -1. Замена &entity_name; на входе ('&nbsp;' => '&#160;' и т.д.)
    process_html_entities(text)

    # 1. Запятые и пробелы
    process_spacing(text) if self.config["spacing"]

    # 1. лапки
    process_quotes(text) if self.config["quotes"]

    # 2. ёлочки
    process_laquo(text) if self.config["laquo"]

    # 3. Инчи
    process_inches(text) if self.config["inches"]

    # 2b. одновременно ёлочки и лапки
    process_compound_quotes(text) if (self.config["quotes"] && self.config["laquo"])

    # 3. тире
    process_dash(text) if self.config["dash"]

    # 3a. тире длинное
    process_emdash(text) if self.config["emdash"]

    # 4. копимарки и трейдрайты
    process_copymarks(text) if self.config["(c)"]

    # 5. +/-
    process_plusmin(text) if self.config["+-"]

    # 5a. 12^C
    process_degrees(text) if self.config["degrees"]

    # 6. телефоны
    process_phones(text) if self.config["phones"]

    # 7. Короткие слова и &nbsp;
    process_wordglue(text) if self.config["wordglue"]

    # 8. Склейка ласт. Тьфу! дефисов.
    process_dashglue(text) if self.config["dashglue"]

    # 8a. Инициалы
    process_initials(text) if self.config['initials']

    # 8b. Троеточия
    process_ellipsises(text) if self.config["wordglue"]

    # 9. Акронимы от Текстиля
    process_acronyms(text) if self.config["acronyms"]

    # заменяем entities на истинные символы
    process_raw_output(text) if self.config["raw_output"]

    text.strip!

    node.native_content = text
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

  # Подставляет "символы" (двоеточие + имя глифа) на нужное значение глифа заданное в данном форматтере
  def substitute_glyphs_in_string(str)
    re = str.dup
    self.config.glyph.each_pair do | key, subst |
      re.gsub!(":#{key.to_s}", subst)
    end
    re
  end

  # Выполняет блок, временно включая настройки переданные в +hash+
  def with_configuration(hash, &block)

    txt = yield

    return txt
  end

  def process_fix_entities(text)
    Gilenson::Config::FORBIDDEN_NUMERIC_ENTITIES.dup.each_pair do |key, rep|
      text.gsub!(/&##{key};/, self.glyph[rep])
    end
  end

  ### Имплементации фильтров
  def process_html_entities(text)
    self.config.glyph.each { |key, value| text.gsub!(/&#{key};/, value)}
  end

  def process_initials(text)
    initials = /([А-Я])[\.]{1,2}[\s]*?([А-Я])[\.]*[\s]*?([А-Я])([а-я])/u
    replacement = substitute_glyphs_in_string('\1.\2.:thinsp\3\4')
    text.gsub!(initials, replacement)
  end

  def process_copy_paste_clearing(text)
    Gilenson::Config::VERBATIM_GLYPHS.each {|key,value| text.gsub!(/#{Regexp.escape(key)}/, glyph[value]) }
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
    _text = '""'
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
    if self.config.raw_output?
      text.gsub!(acronym, '\1%s(\2)' % @thinsp)
    else
      text.gsub!(acronym) do
        expl = $2.to_s
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
    self.config.glyph.values.each do | entity |
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