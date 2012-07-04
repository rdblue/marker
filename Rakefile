require 'rake'
require 'rake/testtask'

task :default => [:test]

desc "Run basic tests"
Rake::TestTask.new("test") { |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = false # currently treetop's metagrammer.rb:10 warns
}

module ReadmeTemplates
  # output some style.  the only parts that are really required are the hr and
  # div.indent styles, the rest just look nice.
  def style( format, positional_args, hash_args, options )
    # colors, from tango icon theme guidelines
    grey = '#BABDB6'
    light_grey = '#EEEEEC'
    red = '#CC0000'
    case format
    when :html
      return <<-END_STYLE
        <style>
        a {
          color: #{red};
          text-decoration: none;
        }

        a:hover {
          text-decoration: underline;
        }

        h1, h2, hr {
          border: 0;
          border-bottom: 1px solid #{grey};
        }

        div.indent, ol, ul, dl {
          padding-left: 2.5em;
          margin: 0em;
        }

        ol.footnotes {
          margin-left: 1em;
          border-left: 1px solid #{grey};
        }

        pre {
          margin: 0.5em;
          padding: 0.5em;
          border: 1px dashed #{grey};
          background-color: #{light_grey};
          -moz-border-radius: 3px;
        }
        </style>
      END_STYLE
    end
  end

  # wraps the first positional arg in <tt> and </tt>
  # this should eventually have markup, since it's really handy.
  def tt( format, positional_args, hash_args, options )
    case format
    when :html
      "<tt>#{positional_args.first}</tt>"
    when :text
      positional_args.first
    end
  end

  # display a template name, with {{ and }}
  def template( format, positional_args, hash_args, options )
    tt( format, ['{{' + positional_args[0] + '}}'], hash_args, options )
  end
end

desc "Compile README.marker to README.html"
task :readme do
  $: << 'lib'
  require 'marker'
  Marker.templates = ReadmeTemplates
  File.open( 'README.html', 'w' ) do |html|
    # read in the markup.  don't use Marker.parse_file so we can escape HTML chars.
    markup = File.read( 'README.marker' )
    # escape < and >, then parse
    parse_tree = Marker.parse( markup.gsub!('<', '&lt;').gsub('>', '&gt;') )
    # generate and write the HTML output
    html.write( parse_tree.to_html )
  end
end
