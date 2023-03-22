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

def package_namespace
  File.basename(Dir.pwd).camelize
end

def version
  @version ||= `bundle exec rails runner "puts #{package_namespace}::VERSION"`.delete("\n")
end

def name
  package_namespace.to_s.underscore
end

def message(version = nil)
  "Bumped #{name} to #{version}"
end

def cmd
  TTY::Command.new uuid: false
end

def add_v1_files
  if File.exist?("./tmp/Gemfile_v1.lock") && File.exist?("./tmp/version_v1.rb")
    say "Cache for the Docker build prepared"
  else
    say "Preparing cache for the Docker build"
    FileUtils.mkdir_p "tmp"
    FileUtils.copy "./Gemfile.lock", "./tmp/Gemfile_v1.lock"
    change_in_file "./tmp/Gemfile_v1.lock", "#{name} (#{version})", "#{name} (1.0.0)"
    FileUtils.copy "./lib/#{name}/version.rb", "./tmp/version_v1.rb"
    change_in_file "./tmp/version_v1.rb", "VERSION = \"#{version}\"", "VERSION = \"1.0.0\""
  end
end

def change_in_file(file, text_to_replace, text_to_put_in_place)
  text = File.read file
  File.open(file, "w+") { |f| f << text.gsub(text_to_replace, text_to_put_in_place) }
end

def destination_path
  "./pkg/#{name}.gem"
end

def remove_previous_gem
  `rm -f #{destination_path}`
end

def image_id
  `docker create #{name}`.to_s.delete("\n")
end

def gems
  yaml_path = Pathname.new("#{__dir__}/../gems.yml")
  YAML.load_file(yaml_path)["gems"].each do |gem, path|
    [gem, File.expand_path(path, Dir.pwd)]
  end.to_h
end
