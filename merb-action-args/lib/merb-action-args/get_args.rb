if RUBY_PLATFORM == "java"
  require File.dirname(__FILE__) / "jruby_args"
else
  begin
    # 1.8: use ParseTree, which is not supported on 1.9 and Rubinius
    require File.dirname(__FILE__) / "mri_args"
  rescue LoadError => e
    # use Method#parameters
    unless Object.method(:inspect).respond_to? :parameters
      raise LoadError.new("Make sure you require 'methopara' before merb-action-args if you want to use action args on Ruby 1.9.1: http://github.com/genki/methopara (original error: #{e.to_s})")
    end
    require File.dirname(__FILE__) / "vm_args"
  end
end

class UnboundMethod
  include GetArgs
end

class Method
  include GetArgs
end
