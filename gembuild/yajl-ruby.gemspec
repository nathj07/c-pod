# Modifed gemspec to use after installation to create a binary gem
#
require './lib/yajl/version'

Gem::Specification.new do |s|
  s.name = %q{yajl-ruby}
  s.version = Yajl::VERSION
  s.authors = ["Brian Lopez", "Lloyd Hilaiel", "Nick Townsend"]
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.email = %q{ntownsend@iparadigms.com}
  s.platform = Gem::Platform::CURRENT
  s.files = %w{
    ./CHANGELOG.md
    ./Gemfile
    ./README.md
    ./yajl-ruby.gemspec
    ./MIT-LICENSE
    ./lib
    ./lib/yajl
    ./lib/yajl/version.rb
    ./lib/yajl/bzip2
    ./lib/yajl/bzip2/stream_reader.rb
    ./lib/yajl/bzip2/stream_writer.rb
    ./lib/yajl/json_gem.rb
    ./lib/yajl/yajl.so
    ./lib/yajl/gzip
    ./lib/yajl/gzip/stream_reader.rb
    ./lib/yajl/gzip/stream_writer.rb
    ./lib/yajl/http_stream.rb
    ./lib/yajl/bzip2.rb
    ./lib/yajl/gzip.rb
    ./lib/yajl/deflate
    ./lib/yajl/deflate/stream_reader.rb
    ./lib/yajl/deflate/stream_writer.rb
    ./lib/yajl/deflate.rb
    ./lib/yajl/json_gem
    ./lib/yajl/json_gem/parsing.rb
    ./lib/yajl/json_gem/encoding.rb
    ./lib/yajl.rb
    }
  s.homepage = %q{http://github.com/brianmario/yajl-ruby}
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{Ruby C bindings to the excellent Yajl JSON stream-based parser library.}
  s.required_ruby_version = ">= 2.0.0"

end
