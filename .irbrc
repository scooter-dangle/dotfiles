require 'irb/completion'
require 'interactive_editor'
require 'wirble'


require 'fileutils'
module FileUtils
    class << self
        alias_method :old_cd, :cd
    end
end

include FileUtils

def cd *args
    FileUtils.old_cd *args unless args.empty?
    FileUtils.pwd
end

def ls dir='.'
    Dir.entries dir
end

def up
    cd '..'
    pwd
end



require 'yaml'

def pp arg
    print YAML.dump arg
end

Wirble.init
Wirble.colorize
print RUBY_VERSION, "\n"

