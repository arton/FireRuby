@echo off
ruby -x "%~f0" %*
@goto endofruby
#!ruby

def to_dosish(path)
  path.gsub(File::SEPARATOR, File::ALT_SEPARATOR)
end

if File.exist?('c:/program files/mozilla firefox')
  firefox = 'c:/program files/mozilla firefox/firefox.exe'
elsif File.exist?('c:/program files (x86)/mozilla firefox')
  firefox = 'c:/program files (x86)/mozilla firefox/firefox.exe'
else
  puts 'no firefox'
  exit 1
end

rubylib = Dir.glob("#{$:[0].gsub(/\/lib\/ruby.+\Z/,'')}/bin/msvcr*.dll")[0]
unless rubylib
  puts 'no rubylib'
  exit 1
else
  rubylib = to_dosish(rubylib)
end

apppath = File.dirname(File.expand_path($0)).gsub(%r|/|, '\\')
if ARGV.size > 0
  arg = "/script \"#{to_dosish(File.expand_path(ARGV[0]))}\""
else
  arg = ''
end  
if $DEBUG || $VERBOSE
  arg << ' -jsconsole'
end
arg << ' -foreground'

system "\"#{to_dosish(firefox)}\" /app \"#{apppath}\\application.ini\" /rubylib \"#{rubylib}\" /win32 true /main \"#{apppath}\\chrome\\content\\main.rb\" #{arg}"

__END__
:endofruby
