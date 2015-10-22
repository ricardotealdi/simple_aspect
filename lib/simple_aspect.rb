require "simple_aspect/version"

module SimpleAspect
  def self.extended(base)
    base.instance_variable_set(
      '@_watcher_aspects', {}
    )
  end

  def aspect_around(method, &block)
    @_watcher_aspects[method] ||= Hash.new({})
    @_watcher_aspects[method][:around_callback] = block
  end

  def method_added(method)
    aspect = @_watcher_aspects.fetch(method, false)
    if aspect
      unless aspect.fetch(:processed, false)
        orig_implementation = instance_method(method)
        aspect[:processed] = true

        around_callback = aspect[:around_callback]
        define_method(method) do |*args, &block|
          result = nil
          around_callback.call(*args) do
             result = orig_implementation.bind(self).call(*args, &block)
          end
          result
        end
      end
    end
  end
end
