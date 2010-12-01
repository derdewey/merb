module Merb
  
  module Test
    module Fixtures
  
      module Controllers

        class Testing < Merb::Controller
          self._template_root = File.dirname(__FILE__) / "views"
        end

        class SessionsController < Testing
    
          def index
            session[:foo] = params[:foo]
            Merb::Config[:session_store]
          end
      
          def regenerate
            session.regenerate
          end
      
          def retrieve
          end
      
          def destroy
            session.clear!
          end
    
        end
    
        class MultipleSessionsController < Testing
    
          def store_in_cookie
            session(:cookie)[:foo] = 'cookie-bar'
          end
      
          def store_in_memory
            session(:memory)[:foo] = 'memory-bar'
          end
      
          def store_in_memcache
            session(:memcache)[:foo] = 'memcache-bar'
          end
      
          def store_in_multiple
            session(:memcache)[:foo] = 'memcache-baz'
            session(:memory)[:foo] = 'memory-baz'
            session(:cookie)[:foo] = 'cookie-baz'
          end
      
          def retrieve
          end
      
        end
  
      end

    end
  end
end
