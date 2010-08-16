# -*- encoding: utf-8 -*- 
# BlueCloth с поддержкой Gilenson
class Gilenson::BlueClothExtra < BlueCloth
  def to_html(*opts)
    ::Gilenson.new(super(*opts)).to_html
  end
end