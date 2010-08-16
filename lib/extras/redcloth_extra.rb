# -*- encoding: utf-8 -*- 
if RedCloth.class == Module
  # RedCloth 4 - частичная поддержка
  class Gilenson::RedClothExtra < RedCloth::TextileDoc
    def to_html(*anything)
      suspended = super(*anything)
      
      # Return quotes to original state
      [187, 171, 8220, 8221].map do |e| 
        suspended.gsub!(/&\##{e};/, '"')
      end
      
      # Return spaces to original state
      [160].map do |e| 
        suspended.gsub!(/&\##{e};/, ' ')
      end
      
      suspended.gilensize
    end
  end
else 
  # RedCloth 3 - RuTils выполняет перегрузку Textile Glyphs в RedCloth, перенося форматирование спецсимволов на Gilenson.
  # Применять как стандартный RedCloth
  #    RuTils::Gilenson::RedClothExtra.new(some_text).to_html
  class Gilenson::RedClothExtra  < RedCloth
    # Этот метод в RedCloth при наличии Гиленсона становится заглушкой
    def htmlesc(text, mode=0)
      text
    end
    
    # А этот метод обрабатывает Textile Glyphs - ту самую типографицу.
    # Вместо того чтобы влезать в чужие таблицы мы просто заменим Textile Glyphs на Gilenson - и все будут рады.  
    def pgl(text) #:nodoc:
      # Подвешиваем пробелы в начале и в конце каждого блока. Тряпка требует чтобы эти пробелы приехали
      # назад нетронутыми.
      spaces =  Array.new(2,'')
      text.gsub!(/\A([\s]+)/) { spaces[0] = $1; '' }
      text.gsub!(/(\s+)\Z/) { spaces[1] = $1; '' }
      text.replace(spaces[0].to_s + ::Gilenson.new(text).to_html + spaces[1].to_s)
    end
  end
end