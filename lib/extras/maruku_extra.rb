# -*- encoding: utf-8 -*- 
# Maruku с поддержкой Gilenson
class Gilenson::MarukuExtra < Maruku
  def to_html(*anything)
    suspended = super
    
    # Return quotes to original state
    [187, 171, 8220, 8221].map do |e| 
      suspended.gsub!( /&\##{e};/, '"')
    end
    
    # Return spaces to original state
    [160].map do |e| 
      suspended.gsub!( /&\##{e};/, ' ')
    end
    
    suspended.gilensize
  end
end