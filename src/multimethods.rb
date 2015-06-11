require_relative "blocks"

class Multimethod
  attr_accessor :sym, :multiblock
  def initialize(sym, multiblock)
    self.sym = sym
    self.multiblock = multiblock
  end

  def invoke_on(target, *args)
    parent_multi_methods = target.class.parent_multimethods(sym)
    merged_block = parent_multi_methods.map{|mm| mm.multiblock }.reduce(self.multiblock, :merge)
    merged_block.invoke_on(target, *args)
  end

  def update_with(multiblock)
    self.multiblock = multiblock.merge(self.multiblock)
  end

end
class Module
  def multimethods
    @multimethods = @multimethods || Hash.new
  end

  def define_multi(sym, multiblock)
    if(!multimethods[sym].nil?)
      multimethods[sym].update_with(multiblock)
    else
      multimethod = Multimethod.new(sym, multiblock)
      multimethods[sym] = (multimethod)
      self.send(:define_method, sym) do |*args|
        multimethod.invoke_on(self, *args)
      end
    end
  end

  def multimethod(sym, &block)
    define_multi(sym, multiblock(&block))
  end

  def parent_multimethods(sym)
    ancestors.drop(1).take_while { |parent|
      !(parent.instance_methods(false).include?(sym) && parent.multimethods[sym] == nil)
    }.map {
        |parent| parent.multimethods[sym]
    }.select { |multi| !multi.nil?}
  end
end