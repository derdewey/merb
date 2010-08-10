# -*- coding: utf-8 -*-


class Numeric
  module Transformer

    # Known formats to use with the app.
    # Users can add their own formats by using
    # `Numeric::Transformer.add_format(:format_name => {})`
    @formats ={
      :us => {
        :number => {      
          :precision => 3, 
          :delimiter => ',', 
          :separator => '.'
        },
        :currency => { 
          :unit => '$',
          :format => '%u%n',
          :precision => 2 
        }
      },
      :uk => {
        :number => {      
        :precision => 3, 
        :delimiter => ',', 
        :separator => '.'
        },
        :currency => { 
          :unit => '&pound;',
          :format => '%u%n',
          :precision => 2 
        }
      },
      :au => {
        :number => {      
        :precision => 3, 
        :delimiter => ',', 
        :separator => '.'
        },
        :currency => { 
          :unit => '$',
          :format => '%u%n',
          :precision => 2 
        }
      },
      :fr => {
        :number => {      
        :precision => 3, 
        :delimiter => ' ', 
        :separator => ','
        },
        :currency => { 
          :unit => '€',
          :format => '%n%u',
          :precision => 2 
        }
      },
      :ru => { 
          :number => {
             :precision => 2,
             :delimiter => ' ',
             :separator => ','
             },
             :currency => {
               :unit => 'р.',
               :format => '%n %u',
               :precision => 2
             }
           }
    }

    # Accessor for @formats
    #
    # @api private
    def self.formats
      @formats
    end
    
    @default_format = @formats[:us]
    

    # Accessor for the default format in use
    #
    #
    # @api public
    def self.default_format
      @default_format
    end

    # Changes the default format to use when transforming a {Numeric} instance.
    #
    # @param [Symbol] format_code Format name to use as the new default format.
    #
    # @return [Hash] a hash representing the default format
    #
    # @api public
    def self.change_default_format(format_code)
      @default_format = (formats[format_code] || default_format)
    end

    # Adds a new format to the existing transforming formats.
    #
    # @param [Hash] format Format defining how to transform numeric values.
    #
    # @api public
    def self.add_format(format)
      formats.merge!(format)
      formats[format]
    end

    # Formats a number with grouped thousands using a delimiter.
    #
    # @see Numeric#with_delimiter
    # @param [Numeric] number
    # @param (see Numeric#with_delimiter)
    # @option options (see Numeric#with_delimiter)
    #
    # @return [String] A string representing the delimited number
    #
    # @example
    #     with_delimiter(12345678)      # => 12,345,678
    #     with_delimiter(12345678.05)   # => 12,345,678.05
    #     with_delimiter(12345678, :FR) # => 12.345.678
    #     with_delimiter(12345678, :US) # => 12,345,678
    #
    # @api private
    def self.with_delimiter(number, format_name = nil, options = {})
      
      format = (formats[format_name] || default_format)[:number].merge(options)

      begin
        parts = number.to_s.split('.')
        parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{format[:delimiter]}")
        parts.join(format[:separator])
      rescue
        number
      end
    end

    # Formats a number with a level of precision.
    #
    # @see Numeric#with_precision
    # @param [Numeric] number
    # @param (see Numeric#with_precision)
    # @option options (see Numeric#with_precision)
    #
    # @return [String] A string representing the delimited number.
    #
    # @example
    #     with_precision(111.2345)                         # => 111.235
    #     with_precision(111.2345, :UK, :precision => 1)   # => "111.2"
    #     with_precision(1234.567, :US, :precision => 1,
    #                                   :separator => ',',
    #                                   :delimiter => '-') # => "1-234,6"
    #
    # @api private
    def self.with_precision(number, format_name = nil, options={})

      format = (formats[format_name] || default_format)[:number].merge(options)

      begin
        rounded_number = (Float(number) * (10 ** format[:precision])).round.to_f / 10 ** format[:precision]
        with_delimiter("%01.#{format[:precision]}f" % rounded_number, format_name, :delimiter => format[:delimiter], :separator => format[:separator])
      rescue
        number
      end
    end

    # Formats a number into a currency string.
    #
    # @see Numeric#to_currency
    # @param [Numeric] number
    # @param (see Numeric#to_currency)
    # @option options (see Numeric#to_currency)
    #
    # @return [String] A string representing the number converted in
    #   currency
    #
    # @example
    #     to_currency(1234567890.506, :US, :precision => 1)  # => "$1,234,567,890.5"
    #     to_currency(1234567890.516, :FR)                   # =>"1 234 567 890,52€"
    #     to_currency(1234567890.516, :US, :unit => "€")     # =>"€1,234,567,890.52"
    #     to_currency(1234567890.506, :US, :precision => 3, :unit => "€")
    #     # => "€1,234,567,890.506"
    #     to_currency(1234567890.506, :AU, :unit => "$AUD", :format => '%n %u')
    #     # => "1,234,567,890.51 $AUD"
    #
    # @api private
    def self.to_currency(number, format_name = nil, options = {})
      
      format = (formats[format_name] || default_format)[:currency].merge(options)

      begin
        format[:format].gsub(/%n/, with_precision(number, 
                                      format_name, :precision  => format[:precision]) ).gsub(/%u/, format[:unit])
      rescue
        number
      end
    end

    # Formats a number into a two digit string.
    #
    # @see Numeric#two_digits
    # @param [Numeric] number
    #
    # @return [String] A string representing the number converted into
    #   a 2 digits string.
    #
    # @example
    #     two_digits(5-3) # => "02"
    #
    # @api private
    def self.two_digits(number)
      (0..9).include?(number) ? "0#{number}" : number.to_s
    end

    # Converts a numeric value representing minutes into a string
    # representing an hour value.
    #
    # @see Numeric#minutes_to_hours
    # @param [Numeric] number Numeric value representing minutes to
    #   convert in hours.
    #
    # @return [String] A string representing the numeric value converted
    #   in hours.
    #
    # @example
    #     minutes_to_hours(315) => "05:15"
    #
    # @api private
    def self.minutes_to_hours(minutes)
      hours = (minutes/60).ceil
      minutes = (minutes - (hours * 60)).to_i
      "#{two_digits(hours)}:#{two_digits(minutes)}"
    end

  end #of Numeric::Transformer

  # Formats a number with grouped thousands using a delimiter, e.g., 12,324.
  # You can pass another format to format the number differently.
  #
  # @param [Symbol] format_name Name of the format to use.
  # @param [Hash] options Options which will overwrite the used format
  # @option options [String] :delimiter
  #   Overwrites the thousands delimiter.
  # @option options [String] :separator
  #   Overwrites the separator between the units.
  #
  # @return [String] A string representing the delimited number
  #
  # @example
  #     12345678.with_delimiter      # => 12,345,678
  #     12345678.05.with_delimiter   # => 12,345,678.05
  #     12345678.with_delimiter(:FR) # => 12.345.678
  #     12345678.with_delimiter(:US) # => 12,345,678
  #
  # @api public
  def with_delimiter(format_name = nil, options = {})
    Transformer.with_delimiter(self, format_name, options)
  end

  # Formats a number with a level of precision, e.g., 112.32 has a
  # precision of 2. You can pass another format to use and even overwrite
  # the format's options.
  #
  # @param (see #with_delimiter)
  # @option options (see #with_delimiter)
  # @option options [Fixnum] :precision
  #   Overwrites the level of precision
  #
  # @return [String] A string representing the delimited number.
  #
  # @example
  #     111.2345.with_precision                         # => 111.235
  #     111.2345.with_precision(:UK, :precision => 1)   # => "111.2"
  #     1234.567.with_precision(:US, :precision => 1,
  #                                  :separator => ',',
  #                                  :delimiter => '-') # => "1-234,6"
  #
  # @api public
  def with_precision(format_name = nil, options = {})
    Transformer.with_precision(self, format_name, options)
  end

  # Formats a number into a currency string, e.g., $13.65. You can
  # specify a format to use and even overwrite some of the format
  # options.
  #
  # @param (see #with_delimiter)
  # @option options [Fixnum] :precision
  #   Sets the level of precision.
  # @option options [String] :unit
  #   Sets the denomination of the currency.
  # @option options [String] :format ("%u%n")
  #   Sets the format of the output string. The field types are:
  #
  #   * `%u`: The currency unit
  #   * `%n`: The number
  #
  # @return [String] A string representing the number converted in
  #   currency
  #
  # @example
  #     1234567890.506.to_currency(:US)                   # => "$1,234,567,890.51"
  #     1234567890.506.to_currency(:US, :precision => 1)  # => "$1,234,567,890.5"
  #     1234567890.516.to_currency(:FR)                   # =>"1 234 567 890,52€"
  #     1234567890.516.to_currency(:US, :unit => "€")     # =>"€1,234,567,890.52"
  #     1234567890.506.to_currency(:US, :precision => 3, :unit => "€")
  #     # => "€1,234,567,890.506"
  #     1234567890.506.to_currency(:AU, :unit => "$AUD", :format => '%n %u')
  #     # => "1,234,567,890.51 $AUD"
  #
  # @api public
  def to_currency(format_name = nil, options = {})
    Transformer.to_currency(self, format_name, options)
  end

  # Formats a number into a two digit string. Basically it prepends an
  # integer to a 2 digits string.
  #
  # @return [String] a string representing the number converted into a
  #   2 digits string.
  #
  # @example
  #     (5-3).two_digits # => "02"
  #
  # @api public
  def two_digits
    Transformer.two_digits(self)
  end

  # Converts a numeric value representing minutes into a string representing
  # an hour value.
  #
  # @return [String] A string representing the numeric value converted
  #   in hours.
  #
  # @example
  #     315.minutes_to_hours => "05:15"
  #
  # @api public
  def minutes_to_hours
    Transformer.minutes_to_hours(self)
  end

end
