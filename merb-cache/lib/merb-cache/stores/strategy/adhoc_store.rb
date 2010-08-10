module Merb::Cache
  # General purpose store, use for your own contexts. Since it wraps access
  # to multiple fundamental stores, it's easy to use this strategy store
  # with distributed cache stores like Memcached.
  class AdhocStore < AbstractStrategyStore
    class << self
      alias_method :[], :new
    end

    attr_accessor :stores

    def initialize(*names)
      @stores = names.map {|n| Merb::Cache[n]}
    end

    def writable?(key, parameters = {}, conditions = {})
      @stores.capture_first {|s| s.writable?(key, parameters, conditions)}
    end

    def read(key, parameters = {})
      @stores.capture_first {|s| s.read(key, parameters)}
    end

    def write(key, data = nil, parameters = {}, conditions = {})
      @stores.capture_first {|s| s.write(key, data, parameters, conditions)}
    end

    def write_all(key, data = nil, parameters = {}, conditions = {})
      @stores.map {|s| s.write_all(key, data, parameters, conditions)}.all?
    end

    def fetch(key, parameters = {}, conditions = {}, &blk)
      read(key, parameters) ||
        @stores.capture_first {|s| s.fetch(key, parameters, conditions, &blk)} ||
        blk.call
    end

    def exists?(key, parameters = {})
      @stores.capture_first {|s| s.exists?(key, parameters)}
    end

    def delete(key, parameters = {})
      @stores.map {|s| s.delete(key, parameters)}.any?
    end

    def delete_all!
      @stores.map {|s| s.delete_all!}.all?
    end
  end
end
