require 'simple_aspect/version'

module SimpleAspect
  require 'thread'

  def self.extended(base)
    base.instance_eval do
      @sa_methods_to_aspect_methods_name = {}
      @sa_ignoring_new_methods = false
      @sa_mutex = Mutex.new
    end
  end

  def aspect_around(
    method,
    instance_around_method_name = sa_instance_around_method_name(method),
    &block
  )
    sa_register_aspect_on_method(method, instance_around_method_name, &block)
  end

  def method_added(method)
    return if sa_should_not_redefine?(method)

    sa_redefine_original_method(method, sa_get_aspect_method_name(method))
  end

  private

  def sa_register_aspect_on_method(method, aspect_method_name, &block)
    sa_set_aspect_method_name(method, aspect_method_name)

    sa_define_aspect_method(aspect_method_name, &block) if block
  end

  def sa_define_aspect_method(aspect_method_name, &block)
    define_method(aspect_method_name, &block)
    instance_eval { private aspect_method_name }
  end

  def sa_redefine_original_method(method, aspect_method)
    sa_avoid_infinite_recursion do
      define_method(
        method, &sa_aspect_method_definition(
          aspect_method, instance_method(method)
        )
      )
    end
  end

  def sa_aspect_method_definition(
    aspect_method, unbinded_original_implementation
  )
    proc do |*args, &block|
      result = nil
      send(aspect_method, *args) do
        result = unbinded_original_implementation.bind(self).call(*args, &block)
      end
      result
    end
  end

  def sa_avoid_infinite_recursion
    sa_mutex.synchronize do
      begin
        sa_ignore_new_methods
        yield
      ensure
        sa_ignore_new_methods(_ignore = false)
      end
    end
  end

  def sa_should_redefine?(method)
    !sa_ignoring_new_methods? && sa_get_aspect_method_name(method)
  end

  def sa_should_not_redefine?(method)
    !sa_should_redefine?(method)
  end

  def sa_get_aspect_method_name(method)
    @sa_methods_to_aspect_methods_name[method]
  end

  def sa_set_aspect_method_name(method, instance_around_method)
    @sa_methods_to_aspect_methods_name[method] = instance_around_method
  end

  def sa_ignoring_new_methods?
    @sa_ignoring_new_methods
  end

  def sa_ignore_new_methods(ignore = true)
    @sa_ignoring_new_methods = ignore
  end

  def sa_mutex
    @sa_mutex
  end

  def sa_instance_around_method_name(method)
    "sa_around_#{method}".to_sym
  end
end
