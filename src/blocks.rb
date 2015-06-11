class TypesMatcher
  include Comparable
  attr_accessor :types

  def initialize(types)
    self.types = types
  end

  def matches(*args)
    types.length == args.length && types.each_with_index.all? {
        |type, i| args[i].is_a? type
    }
  end

  def distance_to(*args)
    types.each_with_index.map {|type, i| args[i].class.ancestors.index(type)}.reduce(:+)
  end

  def eql?(another_matcher)
    another_matcher.is_a?(TypesMatcher) && another_matcher.types == self.types
  end
end

class PartialBlock
  attr_accessor :matcher, :implementation

  def initialize(matching_types, &block)
    self.matcher = TypesMatcher.new(matching_types)
    self.implementation = block
  end

  def matches(*args)
    self.matcher.matches(*args)
  end

  def call(*args)
    if(self.matches(*args))
      self.implementation.call(*args)
    else
      raise 'No match'
    end
  end

  def invoke_on(target, *args)
    target.instance_exec(*args, &self.implementation)
  end

  def distance_to(*args)
    self.matcher.distance_to *args
  end

  def same_matcher(another_partial)
    self.matcher.eql? another_partial.matcher
  end
end

class Multiblock

  attr_accessor :implementations

  def implementations
    @implementations = @implementations || []
  end

  def add_implementation(partial)
    implementations.reject! {|impl| impl.same_matcher partial}
    implementations.push(partial)
  end

  def matches(*args)
    implementations.any? {|impl| impl.matches(*args)}
  end

  def matching_implementations(*args)
    implementations.select {|impl| impl.matches(*args)}
  end

  def implementations_for(*args)
    matching = matching_implementations(*args)
    matching.sort_by { |impl| impl.distance_to(*args)}
  end

  def merge(multiblock)
    merged = Multiblock.new
    merged.implementations = multiblock.implementations.clone
    self.implementations.each { |impl|
      merged.add_implementation impl
    }

    merged
  end

  def call(*args)
    impls = implementations_for(*args)
    if(impls.empty?)
      raise 'No match'
    else
      impls.first.call(*args)
    end
  end

  def invoke_on(target, *args)
    impls = implementations_for(*args)
    impls.first.invoke_on(target, *args)
  end

end

class MultiblockBuilder
  def initialize
    @multiblock = Multiblock.new
  end

  def define_for(arg_types, &implementation)
    @multiblock.add_implementation(PartialBlock.new(arg_types, &implementation))
  end

  def build
    @multiblock
  end
end

def multiblock(&block)
  builder = MultiblockBuilder.new

  builder.instance_eval &block

  builder.build
end