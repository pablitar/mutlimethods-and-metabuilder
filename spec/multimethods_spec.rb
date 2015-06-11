require 'rspec'
require_relative '../src/multimethods'

describe 'multimethods' do
  class A
    def initialize(s)
      @s = s
    end
    mb = Multiblock.new
    mb.add_implementation(
        PartialBlock.new([String, String]) do |s1, s2|
          @s + s1 + s2
        end
    )

    mb.add_implementation(
        PartialBlock.new([String, Integer]) do |s1, n|
          s1 * n
        end
    )

    mb.add_implementation(
        PartialBlock.new([Array]) do |a|
          a.join
        end
    )

    mb.add_implementation(
        PartialBlock.new([Object, Object]) do |a|
          "Objetos concatenados"
        end
    )

    define_multi :concat, mb
  end

  class ACheto
    def initialize(s)
      @s = s
    end

    multimethod :concat do
      define_for [String, String] do |s1, s2|
        @s + s1 + s2
      end
      define_for [String, Integer] do |s1, n|
        s1 * n
      end

      define_for [Array] do |a|
        a.join
      end

      define_for [Object, Object] do |a|
        "Objetos concatenados"
      end
    end
  end

  class B < A

  end

  class C < B

    mb = Multiblock.new
    mb.add_implementation(
        PartialBlock.new([String, String]) do |s1, s2|
          s1 + s2 + @s
        end
    )

    define_multi :concat, mb

  end

  it 'should work with multiblocks' do
    expect(A.new("a").concat("hello", "world")).to eq("ahelloworld")
  end

  it 'should work with chetter syntax' do
    expect(ACheto.new("a").concat("hello", "world")).to eq("ahelloworld")
  end

  it 'should work with multiblocks and inheritance' do
    c = C.new("a")
    expect(c.concat("hello", "world")).to eq("helloworlda")
    expect(c.concat("hello", 3)).to eq("hellohellohello")
  end
end