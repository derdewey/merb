# Form helpers provide a number of methods to simplify the creation of HTML forms.
# They can work directly with models (bound) or standalone (unbound).
module Merb::Helpers::Form

  def _singleton_form_context
    self._default_builder = Merb::Helpers::Form::Builder::ResourcefulFormWithErrors unless self._default_builder
    @_singleton_form_context ||=
      self._default_builder.new(nil, nil, self)
  end

  def form_contexts
    @_form_contexts ||= []
  end

  def current_form_context
    form_contexts.last || _singleton_form_context
  end

  def _new_form_context(name, builder)
    if name.is_a?(String) || name.is_a?(Symbol)
      ivar = instance_variable_get("@#{name}")
    else
      ivar, name = name, name.class.to_s.snake_case.split('::').last
    end
    builder ||= current_form_context.class if current_form_context
    (builder || self._default_builder).new(ivar, name, self)
  end

  def with_form_context(name, builder)
    form_contexts.push(_new_form_context(name, builder))
    ret = yield
    form_contexts.pop
    ret
  end

  # Generates a form tag, which accepts a block that is not directly based
  # on resource attributes.
  #
  #     <%= form :action => url(:controller => "foo", :action => "bar", :id => 1) do %>
  #       <%= text_field :name => "first_name", :label => "First Name" %>
  #       <%= submit "Create" %>
  #     <% end =%>
  #
  # Generates the HTML:
  #
  #     <form action="/foo/bar/1" method="post">
  #       <label for="first_name">First Name</label>
  #       <input type="text" id="first_name" name="first_name" />
  #       <input type="submit" value="Create" />
  #     </form>
  #
  # @param [Hash] attrs HTML attributes
  #
  # @return [String] HTML
  #
  # @note Block helpers use the `<%= =%>` syntax
  # @note A multipart enctype is automatically set if the form contains a
  #   file upload field
  def form(*args, &blk)
    _singleton_form_context.form(*args, &blk)
  end

  # Generates a resource specific form tag which accepts a block, this
  # also provides automatic resource routing.
  #
  #     <%= form_for @person do %>
  #       <%= text_field :first_name, :label => "First Name" %>
  #       <%= text_field :last_name,  :label => "Last Name" %>
  #       <%= submit "Create" %>
  #     <% end =%>
  #
  # The HTML generated for this would be:
  #
  #     <form action="/people" method="post">
  #       <label for="person_first_name">First Name</label>
  #       <input type="text" id="person_first_name" name="person[first_name]" />
  #       <label for="person_last_name">Last Name</label>
  #       <input type="text" id="person_last_name" name="person[last_name]" />
  #       <input type="submit" value="Create" />
  #     </form>
  #
  # @param [Model, Resource] name Model or Resource
  # @param [Hash] attrs HTML attributes
  #
  # @return [String] HTML
  #
  # @note Block helpers use the `<%= =%>` syntax
  def form_for(name, attrs = {}, &blk)
    with_form_context(name, attrs.delete(:builder)) do
      current_form_context.form(attrs, &blk)
    end
  end

  # Creates a scope around a specific resource object like form_for, but
  # does not create the form tags themselves. This makes fields_for
  # suitable for specifying additional resource objects in the same form.
  #
  # @param (see #form_for)
  #
  # @example
  #   <%= form_for @person do %>
  #     <%= text_field :first_name, :label => "First Name" %>
  #     <%= text_field :last_name,  :label => "Last Name" %>
  #     <%= fields_for @permission do %>
  #       <%= check_box :is_admin, :label => "Administrator" %>
  #     <% end =%>
  #     <%= submit "Create" %>
  #   <% end =%>
  def fields_for(name, attrs = {}, &blk)
    attrs ||= {}
    with_form_context(name, attrs.delete(:builder)) do
      capture(&blk)
    end
  end

  # Provides the ability to create quick fieldsets as blocks for your forms.
  #
  #     <%= fieldset :legend => "Customer Options" do %>
  #       ...your form elements
  #     <% end =%>
  #
  # Generates the HTML:
  #
  #     <fieldset>
  #       <legend>Customer Options</legend>
  #       ...your form elements
  #     </fieldset>
  #
  # @param [Hash] attrs HTML attributes and options
  # @option attrs :legend
  #   Adds a legend tag within the fieldset
  #
  # @return [String] HTML
  #
  # @note Block helpers use the `<%= =%>` syntax
  def fieldset(attrs = {}, &blk)
    _singleton_form_context.fieldset(attrs, &blk)
  end

  # @see #fieldset
  # @see #fields_for
  def fieldset_for(name, attrs = {}, &blk)
    with_form_context(name, attrs.delete(:builder)) do
      current_form_context.fieldset(attrs, &blk)
    end
  end

  # Provides a generic HTML checkbox input tag.
  # There are two ways this tag can be generated, based on the
  # option :boolean. If set to false, a "magic" input is generated.
  # Otherwise, an input is created that can be easily used for passing
  # an array of values to the application.
  #
  # @param [Symbol] method Resource attribute
  # @param [Hash] attrs HTML attributes and options
  # @option attrs [Boolean] :boolean
  #   If this is `true`, the input will generate a plain array of selected
  #   options will be passed to the application, instead of a more complex
  #   "bound" value.
  # @todo Docs: proper example
  #
  # @return [String] HTML
  #
  # @example
  #   <%= check_box :name => "is_activated", :value => "1" %>
  #   <%= check_box :name => "choices[]", :boolean => false, :value => "dog" %>
  #   <%= check_box :name => "choices[]", :boolean => false, :value => "cat" %>
  #   <%= check_box :name => "choices[]", :boolean => false, :value => "weasle" %>
  #
  # @example Used with a model:
  #   <%= check_box :is_activated, :label => "Activated?" %>
  def check_box; end

  # Provides a HTML file input.
  #
  # @param [Symbol] name Model or Resource
  # @param [Hash] attrs HTML attributes
  #
  # @return [String] HTML
  #
  # @example
  #   <%= file_field :name => "file", :label => "File" %>
  #
  # @example Used with a model:
  #   <%= file_field :file, :label => "Choose a file" %>
  def file_field; end

  # Provides a HTML hidden input field.
  #
  # @param (see #file_field)
  #
  # @return [String] HTML
  #
  # @example
  #   <%= hidden_field :name => "secret", :value => "some secret value" %>
  #
  # @example Used with a model:
  #   <%= hidden_field :identifier %>
  #   # => <input type="hidden" id="person_identifier" name="person[identifier]" value="#{@person.identifier}" />
  def hidden_field; end

  # Provides a generic HTML label.
  #
  # @param [Hash] attrs HTML attributes
  #
  # @return [String] HTML
  #
  # @example
  #   <%= label "Full Name", :for => "name" %> 
  #   => <label for="name">Full Name</label>
  def label(*args)
    current_form_context.label(*args)
  end

  # Provides a HTML password input.
  #
  # @param (see #file_field)
  #
  # @return [String] HTML
  #
  # @example
  #   <%= password_field :name => :password, :label => "Password" %>
  #   # => <label for="password">Password</label><input type="password" id="password" name="password" />
  #
  # @example Used with a model:
  #   <%= password_field :password, :label => 'New Password' %>
  def password_field; end

  # Provides a HTML radio input tag.
  #
  # @param (see #check_box)
  #
  # @return [String] HTML
  #
  # @example
  #   <%= radio_button :name => "radio_options", :value => "1", :label => "One" %>
  #   <%= radio_button :name => "radio_options", :value => "2", :label => "Two" %>
  #   <%= radio_button :name => "radio_options", :value => "3", :label => "Three", :checked => true %>
  #
  # @example Used with a model:
  #   <%= form_for @person do %>
  #     <%= radio_button :first_name %>
  #   <% end =%>
  def radio_button; end

  # Provides a radio group based on a resource attribute.
  # This is generally used within a resource block such as {#form_for}.
  #
  # @param [Symbol] method Resource attribute
  # @param [Array] arr Choices
  #
  # @return [String] HTML
  #
  # @example
  #   <%# the labels are the options %>
  #   <%= radio_group :my_choice, [5,6,7] %>
  #
  #   <%# custom labels %>
  #   <%= radio_group :my_choice, [{:value => 5, :label => "five"}] %>
  def radio_group; end

  # Provides a HTML select.
  #
  # @param (see #check_box)
  # @option attrs :prompt
  #   Adds an additional option tag with the provided string with no value.
  # @option attrs :selected
  #   The value of a selected object, which may be either a string or an
  #   array.
  # @option attrs :include_blank
  #   Adds an additional blank option tag with no value.
  # @option attrs :collection
  #   The collection for the select options
  # @option attrs [Symbol] :text_method
  #   Method to determine text of an option. For example,
  #   `:text_method => :name`  will call .name on your record object for
  #   what text to display.
  # @option attrs [Symbol] :value_method
  #   Method to determine value of an option.
  #
  # @return [String] HTML
  #
  # @example
  #   <%= select :name, :collection => %w(one two three) %>
  def select; end

  # Provides a HTML textarea tag.
  #
  # @param [String] contents Contents of the text area
  # @param [Hash] attrs HTML attributes
  #
  # @return [String] HTML
  #
  # @example
  #   <%= text_area "my comments", :name => "comments" %>
  #
  # @example Used with a model:
  #   <%= text_area :comments %>
  def text_area; end

  # Provides a HTML text input tag.
  #
  # @param (see #form_for)
  #
  # @return [String] HTML
  #
  # @example
  #   <%= text_field :name => :fav_color, :label => "Your Favorite Color" %>
  #   # => <label for="fav_color">Your Favorite Color</label><input type="text" id="fav_color" name="fav_color" />
  #
  # @example Used with a model:
  #   <%= form_for @person do %>
  #     <%= text_field :first_name, :label => "First Name" %>
  #   <% end =%>
  def text_field; end

  # @todo radio_group helper still needs to be implemented
  %w(text_field password_field hidden_field file_field
  text_area select check_box radio_button radio_group).each do |kind|
    self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{kind}(*args)
        if bound?(*args)
          current_form_context.bound_#{kind}(*args)
        else
          current_form_context.unbound_#{kind}(*args)
        end
      end
    RUBY
  end

  # Generates a HTML button.
  #
  # @param (see #text_area)
  #
  # @return [String] HTML
  #
  # @note Buttons do not always work as planned in IE:
  #   [read more...](http://www.peterbe.com/plog/button-tag-in-IE)
  # @note Not all mobile browsers support buttons:
  #   [read more...](http://nickcowie.com/2007/time-to-stop-using-the-button-element/)
  #
  # @example
  #   <%= button "Initiate Launch Sequence" %>
  def button(contents, attrs = {})
    current_form_context.button(contents, attrs)
  end

  # Generates a HTML delete button.
  #
  # If an object is passed as first parameter, Merb will try to use the
  # resource URL for the object. If the object doesn't have a resource
  # view, pass a URL.
  #
  # @param [Object, String] object_or_url Object to delete or URL to send
  #   the request to.
  # @param [String] contents HTML contained within the button tag.
  # @param [Hash] attrs HTML attributes.
  #
  # @return [String] HTML
  #
  # @example
  #   <%= delete_button @article, "Delete article now", :class => 'delete-btn' %>
  #   <%= delete_button url(:article, @article)%>
  def delete_button(object_or_url, contents="Delete", attrs = {})
    url = object_or_url.is_a?(String) ? object_or_url : resource(object_or_url)
    button_text = (contents || 'Delete')
    tag :form, :class => 'delete-btn', :action => url, :method => :post do
      tag(:input, :type => :hidden, :name => "_method", :value => "DELETE") <<
      tag(:input, attrs.merge(:value => button_text, :type => :submit))
    end
  end

  # Generates a HTML submit button.
  #
  # @param [String] value Sets the `value` attribute.
  # @param [Hash] attrs HTML attributes.
  #
  # @return [String] HTML
  #
  # @example
  #   <%= submit "Process" %>
  def submit(contents, attrs = {})
    current_form_context.submit(contents, attrs)
  end

  # Provides a HTML formatted display of resource errors in an unordered
  # list with a H2 form submission error.
  #
  # @param [Object] obj Model or Resource
  # @param [String] error_class CSS class to use for error container.
  # @param [String] build_li Custom LI tag to wrap each error in.
  # @param [String] header Custom header text for the error container.
  # @param [Boolean] before Display the errors before or inside of the form.
  #
  # @return [String] HTML
  #
  # @example
  #   <%= error_messages_for @person %>
  #   <%= error_messages_for @person {|errors| "You can has probs nao: #{errors.size} of em!"}
  #   <%= error_messages_for @person, lambda{|error| "<li class='aieeee'>#{error.join(' ')}"} %>
  #   <%= error_messages_for @person, nil, 'bad_mojo' %>
  def error_messages_for(obj = nil, opts = {})
    current_form_context.error_messages_for(obj, opts[:error_class] || "error", 
      opts[:build_li] || "<li>%s</li>", 
      opts[:header] || "<h2>Form submission failed because of %s problem%s</h2>",
      opts.key?(:before) ? opts[:before] : true)
  end
  alias error_messages error_messages_for

  private

  def bound?(*args)
    args.first.is_a?(Symbol)
  end

end
