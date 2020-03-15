require 'optparse'

module Tildeconfig
  ##
  # Stores the options for the current run of the program.
  class Options
    attr_accessor :interactive, :system

    def initialize
      self.interactive = true
      self.system = nil
      @parser = OptionParser.new do |parser|
        define_options(parser)
      end
    end

    def define_options(parser)
      parser.banner = "Usage: tildeconfig command [options]"
      parser.separator ""
      parser.separator "options:"

      parser.on("-n", "--non-interactive",
                "Automatically accept prompts") do
        self.interactive = false
      end
      parser.on("-s", "--system SYSTEM",
                "Set which system installer to use") do |s|
        self.system = s.to_sym
      end

      parser.on_tail("-h", "--help", "Show this message") do
        puts parser
        exit
      end
      # Another typical switch to print the version.
      parser.on_tail("-v", "--version", "Show version") do
        puts VERSION
        exit
      end
    end

    def self.parser
      options = Options.new
      options.define_options(parser)

    end

    ##
    # Parses the given arguments, stores them, and returns the options.
    def parse(args)
      @parser.parse!(args)
      self
    end

    ##
    # Prints the help message for the command line program.
    def print_help
      puts @parser
    end

    ## 
    # Checks that all provided options are valid. Rasises an
    # +OptionsError+ when given invalid options.
    def validate
      if @system && !Globals::INSTALLERS.key?(@system)
        raise OptionsError.new("Unknown system #{system}", self)
      end
    end
  end
end
