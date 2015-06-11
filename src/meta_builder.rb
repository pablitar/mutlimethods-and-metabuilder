require_relative "multimethods"

class Builder
  def initialize_properties
    @propiedades.each { |propiedad|
      initialize_property(propiedad)
    }
  end

  def initialize_property(propiedad)
    self.define_singleton_method "#{propiedad}=" do |un_valor|
      @valores[propiedad] = un_valor
    end

    self.singleton_class.instance_eval {
      alias_method "#{propiedad}", "#{propiedad}="
    }
  end

  def initialize(propiedades, target_class)
    @propiedades = propiedades
    @target_class = target_class
    @valores = {}

    initialize_properties
  end

  multimethod :build do
    define_for [] do
      instancia = @target_class.new

      @valores.each {|propiedad, valor|
        instancia.send "#{propiedad}=", valor
      }

      instancia
    end

    define_for [Proc] do |block|
      self.instance_eval &block
      self.build
    end

    define_for [Hash] do |hash|
      @valores = hash
      self.build
    end
  end

end
class MetaBuilder

  def initialize
    @propiedades = []
  end

  def add_property(propiedad)
    @propiedades << propiedad
  end

  def set_target_class(target_class)
    @target_class = target_class
  end

  alias_method :property, :add_property
  alias_method :target_class, :set_target_class

  def self.build &block
    meta_builder = MetaBuilder.new
    meta_builder.instance_eval &block

    meta_builder.build
  end

  def build
    Builder.new(@propiedades, @target_class)
  end
end