require "simple_aspect/version"

module SimpleAspect
  require 'thread'

  def self.extended(base)
    base.instance_eval do
      @_sa_watcher_aspects = {}
      @_sa_ignoring_methods = false
      @_sa_lock = Mutex.new
    end
  end

  def aspect_around(
    method, instance_around_method = instance_around_method_name(method), &block
  )
    @_sa_watcher_aspects[method] = instance_around_method

    if block
      define_method(instance_around_method, &block)
      self.instance_eval { private instance_around_method }
    end
  end

  def method_added(method)
    aspect = @_sa_watcher_aspects[method]

    return if @_sa_ignoring_methods || !aspect

    @_sa_lock.synchronize do
      begin
        @_sa_ignoring_methods = true

        orig_impl = instance_method(method)

        define_method(method) do |*args, &block|
          result = nil

          send(aspect, *args) do
            result = orig_impl.bind(self).call(*args, &block)
          end

          result
        end
      ensure
        @_sa_ignoring_methods = false
      end
    end
  end

  def instance_around_method_name(method)
    "_sa_around_#{method}".to_sym
  end
end
