require 'English'

##
# Defines a module with the given name if it doesn't already exist. May
# also instaed pass a hash with a single key whose value is an array of
# module dependencies. If a block is provided, runs it and passes the
# module with the given name. Raises a +SyntaxError+ if an invalid Hash
# is passed.
def mod(arg)
  name = nil
  dependencies = []
  if arg.is_a? Hash
    if arg.size != 1
      raise TildeConfig::SyntaxError,
            'Incorrect number of arguments in Hash for mod'
    end

    name, dependencies = arg.first
  else
    name = arg
  end
  config = TildeConfig::Configuration.instance
  unless config.modules.key?(name)
    config.modules[name] = TildeConfig::TildeMod.new(name)
  end
  m = config.modules[name]
  m.dependencies.merge(dependencies)
  yield(m) if block_given?
end

##
# Runs +command+ as a shell command. May contain multiple lines, each with a
# command.
#
# If the command could not be found, or the command returns a non-zero exit
# status, raises a +ShellError+.
def sh(command)
  result = system(command)
  return if result

  if result.nil?
    raise TildeConfig::ShellError.new('Shell command not found', command, true)
  end

  raise TildeConfig::ShellError.new('Shell command failed',
                                    command,
                                    false,
                                    exit_status: $CHILD_STATUS)
end

##
# Defines a new system installer with the given name. To install packages, the
# installer yields to the provided block passing an array of packages. Overrides
# existing installers with the same name.
def def_installer(name, &block)
  config = TildeConfig::Configuration.instance
  config.installers[name.to_sym] = TildeConfig::PackageInstaller.new(&block)
end

##
# Defines a new package with the given name and system names. The +system_names+
# parameter is a hash from symbols representing package names to strings
# representing the name of the package on that system. Overrides existing
# package if exists.
def def_package(name, system_names = {})
  config = TildeConfig::Configuration.instance
  config.system_packages[name] =
    TildeConfig::SystemPackage.new(name, system_names)
end

# Defines a command with the given name. This command will be callable on
# modules. When called it will yield to the provided block passing the module
# itself and the rest of the arguments.
def def_cmd(name)
  if TildeConfig::TildeMod.method_defined?(name)
    TildeConfig::TildeMod.remove_method(name)
  end
  # The given block should take in (module, *other_args).
  TildeConfig::TildeMod.define_method(name, ->(*args) { yield(self, *args) })
end

def settings
  TildeConfig::Configuration.instance.settings
end
