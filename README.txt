= gilenson

* http://github.com/julik/gilenson

== DESCRIPTION:

Обработчик типографских символов в HTML согласно общепринятым правилам.
Посвящается П.Г.Гиленсону[http://www.rudtp.ru/lib.php?book=172], благодаря которому русские правила тех.
редактуры еще как минимум 20 лет останутся бессмысленно старомодными.

Разработчики gilenson - {Julik}[http://julik.nl], {Mash}[http://imfo.ru], {Yaroslav Markin}[http://markin.net/]

== ФУНКЦИИ

Gilenson расставит в тексте "умные" правильные кавычки (русские - для кириллицы, английские - для латиницы),
заменит "хитрые" пунктуационные символы на entities и отформатирует знаки типа (c), (tm), телефоны и адреса.

Gilenson базируется на коде Typografica[http://pixel-apes.com/typografica] от PixelApes,
который был приведен к положенному в Ruby стандарту. Основные отличия Gilenson от Typografica на PHP:

* работа только и полностью в UTF-8 (включая entities, применимые в XML)
* поддержка "raw"-вывода (символов вместо entities) - текст выводимый Gilenson можно верстать на бумаге

== ИСПОЛЬЗОВАНИЕ:

Программой gilensize поставляющейся в комплекте
  cat файл_с_текстом_в_utf8.txt | gilensize > красивый_документ.txt

Из кода - как фильтр

  formatter = Gilenson.new
  formatter.configure(:dash=>true)
  for string in strings
    puts formatter.process(string)
  end

или через метод ++gilensize++ для любой строковой переменной

  %{ И вот они таки "приехали"}.gilensize => 'И&#160;вот они&#160;таки &#171;приехали&#187;'

Все дополнительные настройки в таком случае передаются форматтеру

  %{ И вот они таки "приехали"}.gilensize(:laquo=>false) => 'И&#160;вот они&#160;таки "приехали"'

Настройки регулируются через методы
  formatter.dashglue = true
или ассоциированным хешем
  formatter.configure!(:dash=>true, :quotes=>false)

Хеш также можно передавать как последний аргумент методам process и to_html,
в таком случае настройки будут применены только при этом вызове

  beautified = formatter.process(my_text, :dash=>true)

В параметры можно подставить также ключ :all чтобы временно включить или выключить все фильтры

  beautified = formatter.process(my_text, :all=>true)

Помимо этого можно пользоваться каждым фильтром по отдельности используя метод +apply+

Можно менять глифы, которые форматтер использует для подстановок. К примеру,
  formatter.glyph[:nbsp] = '&nbsp;'
заставит форматтер расставлять "традиционные" неразрывные пробелы.
Именно это - большая глупость, но другие глифы заменить может быть нужно.

=== Настройки форматтера

* "inches" - преобразовывать дюймы в знак дюйма;
* "laquo" - кавычки-ёлочки
* "quotes" - кавычки-английские лапки
* "dash" -  проставлять короткое тире (150)
* "emdash" - длинное тире двумя минусами (151)
* "initials" - проставлять тонкие шпации в инициалах
* "copypaste" - замена непечатных и "специальных" юникодных символов на entities
* "(c)" - обрабатывать знак копирайта
* "(r)", "(tm)", "(p)", "+-" - спецсимволы, какие - понятно
* "acronyms" - сворачивание пояснений к аббревиатурам (пояснение - в скобках после аббревиатуры без пробела). Пояснение будет "приклеено" к аббревиатуре полукруглой шпацией.
* "degrees" - знак градуса
* "dashglue", "wordglue" - приклеивание предлогов и дефисов
* "spacing" - запятые и пробелы, перестановка
* "phones" - обработка телефонов
* "html" - при false - запрет использования тагов html
* "de_nobr" - при true все <nobr/> заменяются на <span class="nobr"/>
* "raw_output" - (по умолчанию false) - при true вместо entities выводятся UTF-символы.
  Это нужно чтобы обработанный текст верстать на бумаге.
* "skip_attr" - (по умолчанию false) - при true не отрабатывать типографику в атрибутах тегов (title, alt)
* "skip_code" - (по умолчанию true) - при true не отрабатывать типографику внутри <code/>, <tt/>, CDATA

== УСТАНОВКА:

* sudo gem install gilenson

== ЛИЦЕНЗИЯ:

(The MIT License)

Copyright (c) 2003-2004 Julik Tarkhanov, Danil Ivanov and contributors

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
