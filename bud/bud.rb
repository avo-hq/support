#!/usr/bin/env ruby
# require "bundler/setup"
require "dry/cli"
require "active_support/core_ext/class/attribute"
require "yaml"
require "tty-command"
require "fileutils"
require "active_support/core_ext/string"
require "bump"
require_relative "support"

module Releaser
  VERSION = "0.0.1"

  module CLI
    module Commands
      extend Dry::CLI::Registry

      class Version < Dry::CLI::Command
        desc "Print version"

        def call(*)
          puts VERSION
        end
      end

      class Bump < Dry::CLI::Command
        desc "Bump gem"

        argument :level, desc: "major|minor|patch"

        def call(level: "patch", **)
          version, _ = ::Bump::Bump.run(level, commit: false, bundle: false, tag: false)
          cmd.run("bundle")
          say message(version)
        end
      end

      class Build < Dry::CLI::Command
        desc "Build the gem"

        def call(*)
          FileUtils.mkdir_p "pkg"

          remove_previous_gem

          # We prepare these files so the cache does not get busted once the version is incremented in Gemfile.lock
          add_v1_files

          build_docker_image

          copy_from_container
        end
      end

      class Push < Dry::CLI::Command
        desc "Push the gem"

        def call(*)
          `gem push --key github --host https://rubygems.pkg.github.com/avo-hq ./pkg/#{name}.gem`
        end
      end

      class Commit < Dry::CLI::Command
        desc "Commit the version change"

        def call(*)
          `git add ./lib/#{name}/version.rb`
          `git add ./Gemfile.lock`

          tag = "v#{version}"

          `git commit -m "#{message(version)}"`
          `git tag -a -m "#{message(version)}" #{tag}`

          `git push --follow-tags`
        end
      end

      class Release < Dry::CLI::Command
        desc "Release the gem"

        def call(*)
          # 1. Bump gem version
          Bump.new.call
          # 2. Build the gem
          Build.new.call
          # 3. Push to GitHub packages
          Push.new.call
          # 4. commit & upload tag to git
          #    GitHub action will generate the release with release notes
          Commit.new.call
        end
      end

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "bump", Bump
      register "build", Build
      register "push", Push
      register "commit", Commit
      register "release", Release
    end
  end
end

Dry::CLI.new(Releaser::CLI::Commands).call
