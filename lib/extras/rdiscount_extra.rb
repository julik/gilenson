# -*- encoding: utf-8 -*- 
# RDiscount с поддержкой Gilenson
class Gilenson::RDiscountExtra < RDiscount
  def to_html(*opts)
    ::Gilenson.new(super(*opts)).to_html
  end
end