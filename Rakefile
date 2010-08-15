# -*- ruby -*-

require 'rubygems'
require 'hoe'
require File.dirname(__FILE__) + "/lib/gilenson"

DOCOPTS = %w(--charset utf-8 --promiscuous)

r = Hoe.spec 'gilenson' do | p |
  p.developer('Julik Tarkhanov', 'me@julik.nl')
  p.version =  Gilenson::VERSION
end
r.spec.rdoc_options += DOCOPTS

# vim: syntax=ruby
