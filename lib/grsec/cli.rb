# frozen_string_literal: true

require "thor"
require "thor/actions"
require "runcom"
require "pathname"

$thor_runner = false # rubocop:disable Style/GlobalVars

module Grsec
  # The Command Line Interface (CLI) for the gem.
  class CLI < Thor
    include Thor::Actions

    package_name Identity::VERSION_LABEL

    def self.configuration
      Runcom::Config.new "#{Identity::NAME}/configuration.yml"
    end

    def initialize args = [], options = {}, config = {}
      super args, options, config
      @configuration = self.class.configuration
    rescue Runcom::Errors::Base => error
      abort error.message
    end

    desc "-c, [--config]", "Manage gem configuration."
    map %w[-c --config] => :config
    method_option :edit,
                  aliases: "-e",
                  desc: "Edit gem configuration.",
                  type: :boolean,
                  default: false
    method_option :info,
                  aliases: "-i",
                  desc: "Print gem configuration.",
                  type: :boolean,
                  default: false
    def config
      path = configuration.current

      if options.edit? then `#{ENV["EDITOR"]} #{path}`
      elsif options.info?
        path ? say(path) : say("Configuration doesn't exist.")
      else help :config
      end
    end

    desc "-v, [--version]", "Show gem version."
    map %w[-v --version] => :version
    def version
      say Identity::VERSION_LABEL
    end

    desc "-h, [--help=COMMAND]", "Show this message or get help for a command."
    map %w[-h --help] => :help
    def help task = nil
      say and super
    end

    desc "-g, [--generate] PATH", "Generate the documentation."
    map %w[-g --generate] => :generate
    # TODO: Factor out generate logic to generator class
    # :reek:FeatureEnvy
    # :reek:TooManyStatements
    def generate path
      base_path = Pathname.new path
      collections = {roles: parse_roles(base_path), controls: parse_controls(base_path)}
      references = collections.transform_values(&:references)
      collections.each_value { |collection| collection.parse references }
      collections[:controls].controls.each { |control| ControlRenderer.new(control).render }
    end

    private

    # :reek:UtilityFunction
    def parse base_path, glob, collection
      definitions = base_path.glob glob
      definitions.each do |file|
        definition = File.read file
        collection.instance_eval definition
      end
      collection
    end

    def parse_controls base_path
      parse base_path, "controls/*_controls.rb", ControlCollection.new
    end

    def parse_roles base_path
      parse base_path, "roles/*_role.rb", RoleCollection.new
    end

    attr_reader :configuration
  end
end
