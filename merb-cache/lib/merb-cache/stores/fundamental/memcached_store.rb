require 'memcached'

module Merb::Cache
  # Memcached store uses one or several Memcached
  # servers for caching. It's flexible and can be used
  # for fragment caching, action caching, page caching
  # or object caching.
  class MemcachedStore < AbstractStore
    attr_accessor :namespace, :servers, :memcached

    # @param [Hash] config Configuration options
    # @option config [String] :namespace
    # @option config [Array<String>] :servers (["127.0.0.1:11211"])
    #   Memcache servers.
    def initialize(config = {})
      @namespace = config[:namespace]
      @servers = config[:servers] || ["127.0.0.1:11211"]

      connect(config)
    end

    # Memcached store consideres all keys and parameters
    # writable.
    def writable?(key, parameters = {}, conditions = {})
      true
    end

    # Reads key from the cache.
    def read(key, parameters = {})
      begin
        @memcached.get(normalize(key, parameters))
      rescue Memcached::NotFound, Memcached::Stored
        nil
      end
    end

    # Writes data to the cache using key, parameters and conditions.
    def write(key, data = nil, parameters = {}, conditions = {})
      if writable?(key, parameters, conditions)
        begin
          @memcached.set(normalize(key, parameters), data, expire_time(conditions))
          true
        rescue
          nil
        end
      end
    end

    # Fetches cached data by key if it exists. If it does not,
    # uses passed block to get new cached value and writes it
    # using given key.
    def fetch(key, parameters = {}, conditions = {}, &blk)
      read(key, parameters) || (writable?(key, parameters, conditions) && write(key, value = blk.call, parameters, conditions) && value)
    end

    # returns true/false/nil based on if data identified by the key & parameters
    # is persisted in the store.
    #
    # With Memcached 1.2 protocol the only way to find if key exists in
    # the cache is to read it. It is very fast and shouldn't be a concern.
    def exists?(key, parameters = {})
      begin
        @memcached.get(normalize(key, parameters)) && true
      rescue  Memcached::Stored
        true
      rescue Memcached::NotFound
        nil
      end
    end

    # Deletes entry from cached by key.
    def delete(key, parameters = {})
      begin
        @memcached.delete(normalize(key, parameters))
      rescue Memcached::NotFound
        nil
      end
    end

    # Flushes the cache.
    def delete_all
      @memcached.flush
    end

    def clone
      twin = super
      twin.memcached = @memcached.clone
      twin
    end

    # Establishes connection to Memcached.
    #
    # @param [Hash] config Configuration options passed to memcached. Only
    #   the options mentioned below are passed through.
    # @option config [Boolean] :buffer_requests (false)
    #   Use bufferring
    # @option config [Boolean] :no_block (false)
    #   Use non-blocking async I/O.
    # @option config [Boolean] :support_cas (false)
    #   Support CAS.
    #
    # @see http://blog.evanweaver.com/files/doc/fauna/memcached/classes/Memcached.html memcached gem documentation
    def connect(config = {})
      @memcached = ::Memcached.new(@servers, config.only(:buffer_requests, :no_block, :support_cas).merge(:namespace => @namespace))
    end

    # Returns cache key calculated from base key and SHA2 hex from
    # parameters.
    def normalize(key, parameters = {})
      parameters.empty? ? "#{key}" : "#{key}--#{parameters.to_sha2}"
    end

    # Returns expiration timestamp if `:expire_in` key is given.
    def expire_time(conditions = {})
      if t = conditions[:expire_in]
        Time.now + t
      else
        0
      end
    end
  end
end
