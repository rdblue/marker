require 'rubygems'

SPEC = Gem::Specification.new do |s|
  s.name = 'marker'
  s.summary = 'A markup parser that outputs html and text.  Syntax is similar to MediaWiki.'
  s.version = '0.2.0'
  s.author = 'Ryan Blue'
  s.email = 'rdblue@gmail.com'
  s.homepage = 'http://github.com/rdblue/marker'
  s.files = Dir.glob( 'bin/*' ) +
            Dir.glob( 'lib/**/*.rb' ) +
            Dir.glob( 'lib/**/*.treetop' )
  s.test_files = Dir.glob( 'test/*.rb' )
  s.executables << 'marker'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.add_dependency( 'treetop', '>= 1.4.2' )
end
