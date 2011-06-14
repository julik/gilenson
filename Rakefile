# -*- ruby -*-

require 'hoe'
r = Hoe.spec 'gilenson' do | p |
  Hoe::RUBY_FLAGS.gsub!(/^\-w/, '') # No thanks
  
  p.developer('Julik Tarkhanov', 'me@julik.nl')
  p.readme_file = 'README.rdoc'
  p.extra_rdoc_files  = FileList['*.rdoc'] + FileList['*.txt']
end

# vim: syntax=ruby
