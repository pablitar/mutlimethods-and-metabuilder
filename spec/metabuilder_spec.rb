require 'rspec'
require_relative '../src/meta_builder'
require_relative 'perro'


describe 'Metabuilder' do

  it 'should build a builder' do

    meta_builder = MetaBuilder.new

    meta_builder.add_property('raza')
    meta_builder.add_property('edad')
    meta_builder.add_property('peso')
    meta_builder.set_target_class(Perro)

    builder_de_perros = meta_builder.build

    builder_de_perros.edad = 4
    builder_de_perros.peso = 14
    builder_de_perros.raza = 'fox terrier'

    perro = builder_de_perros.build()

    check_perro(perro)
  end

  it 'should build a builder with cheter syntax' do
    builderDePerros =
        MetaBuilder.build {
          property('raza')
          property('edad')
          property('peso')
          target_class(Perro)
        }

    perro = builderDePerros.build proc {
      edad 4
      peso 14
      raza 'fox terrier'
    }

    check_perro perro
  end

  def check_perro(perro)
    expect(perro.edad).to eq 4
    expect(perro.peso).to eq 14
    expect(perro.raza).to eq 'fox terrier'
  end

end