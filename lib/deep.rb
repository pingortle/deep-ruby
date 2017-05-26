module Deep
  def deep(&block)
    block.call self
    visit_children &block
  end

  private
    def visit_children(&block)
      return unless self.respond_to? :each

      self.each do |x|
        DeepObject.new(x).deep &block
       end
    end

    class DeepObject < SimpleDelegator
      include Deep

      def deep
        super do |object|
          if object.is_a? DeepObject
            yield object.__getobj__
          else
            yield object
          end
        end
      end
    end
end
