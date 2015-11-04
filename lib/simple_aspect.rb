require "simple_aspect/version"

module SimpleAspect
  require 'thread'

  def self.extended(base)
    base.instance_variable_set(
      '@_sa_watcher_aspects', {}
    )
    base.instance_variable_set(
      '@_sa_ignoring_methods', false
    )
    base.instance_variable_set(
      '@_sa_lock', Mutex.new
    )
  end

  def aspect_around(method, &block)
    @_sa_watcher_aspects[method] = block
  end

  def method_added(method)
    aspect = @_sa_watcher_aspects[method]

    return if @_sa_ignoring_methods || !aspect

    @_sa_lock.synchronize do
      begin
        @_sa_ignoring_methods = true

        orig_impl = instance_method(method)
        around_callback = aspect

        define_method(method) do |*args, &block|
          result = nil

          # executing `around_callback` with the instance's binding
          instance_exec(
            *args, proc { result = orig_impl.bind(self).call(*args, &block) },
            &around_callback
          )

          result
        end
      ensure
        @_sa_ignoring_methods = false
      end
    end
  end
end
