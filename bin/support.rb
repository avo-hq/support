def say(text)
  puts "=> #{yellow(text)}"
end

def yell(text)
  puts "=> #{red(text)}"
end

def colorize(text, color_code)
  "#{color_code}#{text}\e[0m"
end

def yellow(text)
  colorize(text, "\e[33m")
end

def red(text)
  colorize(text, "\e[31m")
end

def green(text)
  colorize(text, "\e[32m")
end

def gemspec_path
  Dir["#{Dir.pwd}/*.gemspec"].first
end

def gemspec
  Gem::Specification.load(gemspec_path)
end

def version
  @version ||= gemspec.version.to_s
end

# fetch the Avo version from the avo gem
def avo_gem_version
  require_relative "../../avo/lib/avo/version"
  @avo_version ||= Avo::VERSION
end

def gemspec_name
  gemspec.name
end

def name
  gemspec_name.gsub("avo-", "")
end

def cmd(**options)
  TTY::Command.new uuid: false, **options
end

def bump_message(version)
  "Bumped #{gemspec_name} to #{version}"
end

def change_in_file(file, regex, text_to_put_in_place)
  text = File.read file
  File.open(file, "w+") { |f| f << text.gsub(/#{regex}/, text_to_put_in_place) }
end

def destination_path
  "./pkg/#{gemspec_name}.gem"
end

def remove_previous_gem
  `rm -f #{destination_path}`
end

def image_id
  `docker create #{name}`.to_s.delete("\n")
end

def bundler_token
  @token ||= `bundle config get https://packager.dev/avo-hq`.match(/^.*: "(.*)"$/).captures.first
end

def gem_root_path
  `readlink $(whereis bud)`.chomp.gsub("/support/bin/bud", "")
end

def gem_path(gem_name)
  "#{gem_root_path}/#{gem_name}"
end

def chdir_to_gem(gem_name, &block)
  @path = gem_path(gem_name)
  if block_given?
    Dir.chdir(@path) do
      @path = gem_path(gem_name)
      Bundler.with_unbundled_env do
        instance_exec(&block)
      end
    end
  else
    Dir.chdir(@path)
  end
end