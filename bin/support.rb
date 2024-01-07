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

def gemspec_name
  gemspec.name
end

def name
  gemspec_name.gsub("avo-", "")
end

def message(version = nil)
  "Bumped #{name} to #{version}"
end

def cmd
  TTY::Command.new uuid: false
end

def add_v1_files
  say "Preparing cache for the Docker build"
  FileUtils.mkdir_p "tmp"
  FileUtils.copy "./Gemfile.lock", "./tmp/Gemfile_v1.lock"
  change_in_file "./tmp/Gemfile_v1.lock", /.*#{name} \(.*/, "    #{name} (1.0.0)"
  version_file_path = gemspec.files.find { |file| file.ends_with? "/version.rb" }
  FileUtils.copy version_file_path, "./tmp/version_v1.rb"
  change_in_file "./tmp/version_v1.rb", /.*VERSION = .*/, "  VERSION = \"1.0.0\""
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

def gems
  yaml_path = Pathname.new("#{__dir__}/../gems.yml")
  YAML.load_file(yaml_path)["gems"].each do |gem, path|
    [gem, File.expand_path(path, Dir.pwd)]
  end.to_h
end
