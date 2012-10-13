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



class Object
    alias_method :m, :method
end


def russian_roulette
    -> do
        reset = -> { Array.new(5, nil.to_s).push('exit').shuffle }
        barrel = reset[]
        -> do
            if barrel.size == 1 then
                barrel = reset[]
            else
                eval barrel.pop
            end
            barrel.shuffle!.dup
        end
    end[]
end
