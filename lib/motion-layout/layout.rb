module Motion
  class Layout
    def initialize(delegate = nil, &block)
      @delegate = delegate
      @verticals   = []
      @horizontals = []
      @metrics     = {}

      yield self
      strain
    end

    def metrics(metrics)
      @metrics = metrics
    end

    def subviews(*subviews)
      if subviews[0].is_a? Hash
        @subviews = subviews.subviews[0]
      elsif (subviews[0].is_a?(String) || subviews[0].is_a?(Symbol)) and @delegate
        @subviews = {}
        subviews.each do |v|
          if @delegate.respond_to?(v)
            @subviews[v.to_s] = self.send(v)
          elsif @delegate.instance_variable_defined? "@#{v}"
            @subviews[v.to_s] = @delegate.instance_variable_get "@#{v}"
          else
            raise "Couldn't find method or instance variable '#{v}' on the delegate"
          end
        end
      else
        raise "subviews only accepts a hash or an array (if delegate is defined)"
      end

    end

    def view(view)
      @view = view
    end

    def horizontal(horizontal, options = NSLayoutFormatDirectionLeadingToTrailing)
      @horizontals << [horizontal, options]
    end

    def vertical(vertical, options = NSLayoutFormatDirectionLeadingToTrailing)
      @verticals << [vertical, options]
    end

    private

    def strain
      @subviews.values.each do |subview|
        subview.translatesAutoresizingMaskIntoConstraints = false
        @view.addSubview(subview)
      end

      constraints = []
      constraints += @verticals.map do |vertical, options|
        NSLayoutConstraint.constraintsWithVisualFormat("V:#{vertical}", options:options, metrics:@metrics, views:@subviews)
      end
      constraints += @horizontals.map do |horizontal, options|
        NSLayoutConstraint.constraintsWithVisualFormat("H:#{horizontal}", options:options, metrics:@metrics, views:@subviews)
      end

      @view.addConstraints(constraints.flatten)
    end
  end
end
