#  require 'irb/completion'
#  require 'interactive_editor'
#  require 'wirble'
#  
#  
#  require 'fileutils'
#  module FileUtils
#      class << self
#          alias_method :old_cd, :cd
#      end
#  end
#  
#  include FileUtils
#  
#  def cd *args
#      FileUtils.old_cd *args unless args.empty?
#      FileUtils.pwd
#  end
#  
#  def ls dir='.'
#      Dir.entries dir
#  end
#  
#  def up
#      cd '..'
#      pwd
#  end
#  
#  
#  
#  require 'yaml'
#  
#  def pp arg
#      print YAML.dump arg
#  end
#  
#  Wirble.init
#  Wirble.colorize
#  print RUBY_VERSION, "\n"
#  
#  
#  
#  class Object
#      alias_method :m, :method
#  
#      def show_params type = :inst
#          case type
#          when :inst
#              __show_params_inst
#          when :plain
#              __show_params_plain
#          end
#      end
#  
#      private
#      def __show_params_plain
#          self.methods(false).each_with_object({}) do |meth, hash|
#              hash[meth] = self.method(meth).parameters
#          end
#      end
#  
#      def __show_params_inst
#          self.instance_methods(false).each_with_object({}) do |meth, hash|
#              hash[meth] = self.instance_method(meth).parameters
#          end
#      end
#  
#      public
#      def show_arities type = :inst
#          case type
#          when :inst
#              __show_arities_inst
#          when :plain
#              __show_arities_plain
#          end
#      end
#  
#      private
#      def __show_arities_plain
#          self.methods(false).each_with_object({}) do |meth, hash|
#              hash[meth] = self.method(meth).arity
#          end
#      end
#  
#      def __show_arities_inst
#          self.instance_methods(false).each_with_object({}) do |meth, hash|
#              hash[meth] = self.instance_method(meth).arity
#          end
#      end
#  end
#  
#  
#  def russian_roulette
#      -> do
#          reset = -> { Array.new(5, nil.to_s).push('exit').shuffle }
#          barrel = reset[]
#          -> do
#              if barrel.size == 1 then
#                  barrel = reset[]
#              else
#                  eval barrel.pop
#              end
#              barrel.shuffle!.dup
#          end
#      end[]
#  end
