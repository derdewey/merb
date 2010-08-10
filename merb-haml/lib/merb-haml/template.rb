module Merb::Template

  class Haml

    # Defines a method for calling a specific HAML template.
    #
    # @param [String] path Path to the template file.
    # @param [#to_s] name The name of the template method.
    # @param [Array<Symbol>] locals A list of locals to assign from the
    #   args passed into the compiled template.
    # @param [Class, Module] mod The class or module wherein this method
    #   should be defined.
    def self.compile_template(io, name, locals, mod)
      path = File.expand_path(io.path)
      config = (Merb::Plugins.config[:haml] || {}).inject({}) do |c, (k, v)|
        c[k.to_sym] = v
        c
      end.merge :filename => path
      template = ::Haml::Engine.new(io.read, config)
      template.def_method(mod, name, *locals)
      name
    end
  
    module Mixin
      # @param [String] string The string to add to the HAML buffer.
      # @param [Binding] binding Not used by HAML, but is necessary to
      #   conform to the {Merb::AbstractController#concat concat}`_*`
      #   interface.
      def concat_haml(string, binding)
        haml_buffer.buffer << string
      end
      
    end
    Merb::Template.register_extensions(self, %w[haml])  
  end
end

module Haml
  class Engine

    # @param [Class, Module] object The class or module wherein this
    #   method should be defined.
    # @param [#to_s] name The name of the template method.
    # @param *local_names Local names to define in the HAML template.
    def def_method(object, name, *local_names)
      method = object.is_a?(Module) ? :module_eval : :instance_eval

      setup = "@_engine = 'haml'"

      object.send(method, "def #{name}(_haml_locals = {}); #{setup}; #{precompiled_with_ambles(local_names)}; end",
                  @options[:filename], 0)
    end
 
  end
end
