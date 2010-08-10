module Merb::Helpers::Text
  # Allows you to cycle through elements in an array.
  #
  # @param [Array, Hash] values Array of objects to cycle through. The last
  #   element of array can be a hash with the key of `:name` to specify the
  #   name of the cycle.
  #
  # @return [String]
  #
  # @note Default name is `:default`.
  #
  # @example
  #     5.times { cycle("odd! ","even! "}
  #     # => "odd! even! odd! even! odd! "
  def cycle(*values)
    options = extract_options_from_args!(values) || {}
    key = (options[:name] || :default).to_sym
    (@cycle_positions ||= {})[key] ||= {:position => -1, :values => values}
    unless values == @cycle_positions[key][:values]
      @cycle_positions[key] = {:position => -1, :values => values}
    end
    current = @cycle_positions[key][:position]
    @cycle_positions[key][:position] = current + 1
    values.at( (current + 1) % values.length).to_s
  end

  # Reset a cycle.
  #
  # @param [Symbol, String] name Name of the cycle.
  #
  # @return [true, nil] True if successful, otherwise nil.
  # @todo Docs, correctness, true/false would be better?
  #
  # @note Default name is `:default`.
  #
  # @example
  #   cycle("odd! ","even! ","what comes after even?")
  #   cycle("odd! ","even! ","what comes after even?")
  #   reset_cycle
  #   cycle("odd! ","even! ","what comes after even?")
  #   # => "odd! even! odd! "
  def reset_cycle(name = :default)
    (@cycle_positions[name.to_sym] = nil) &&
      true if @cycle_positions && @cycle_positions[name.to_sym]
  end
end

module Merb::GlobalHelpers
  include Merb::Helpers::Text
end
