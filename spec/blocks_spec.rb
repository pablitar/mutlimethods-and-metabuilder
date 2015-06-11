require 'rspec'
require_relative '../src/blocks'

describe 'multiblocks' do
  mb = Multiblock.new
  mb.add_implementation(
      PartialBlock.new([String, String]) do |s1, s2|
        s1 + s2
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

  it 'should work' do
    expect(mb.call("hello", "world")).to eq("helloworld")
    expect(mb.call("hello", 3)).to eq("hellohellohello")
  end

  it 'should select the more specific' do
    expect(mb.call("hello", Object.new)).to eq("Objetos concatenados")
    expect(mb.call("hello", 3)).to eq("hellohellohello")
  end
end