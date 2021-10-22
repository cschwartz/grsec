# frozen_string_literal: true

module Grsec
  def self.define_type type_name, &block
    Type.new(type_name)
        .tap { |type| type.instance_eval(&block) }
        .generate
  end

  class Type
    def initialize type
      @type = type
      @id = nil
      @attributes = []
    end

    def identified_by *reference_items
      @id = reference_items
    end

    def attribute name:, **type
      @attributes << {name: name, **type}
    end

    def options *values
      {type: :options, options: values}
    end

    def reference target
      {type: :reference, target: target}
    end

    def description
      {type: :description}
    end

    def string
      {type: :string}
    end

    def generate
      reference_type = Grsec.generate_references @id
      collection reference_type
    end

    private

    def generate_entity
      Struct.new(*[:reference].append(*fields), keyword_init: true)
    end

    def fields
      @attributes.map { |attribute| attribute[:name] }
    end

    # TODO: Refactor to CollectionGenerator.
    # :reek:TooManyStatements
    def collection reference_type
      parser_klass = parser
      Class.new(ItemsCollection).tap do |collection|
        collection.define_method :initialize do
          super reference_class: reference_type, parser_class: parser_klass
        end

        collection.define_method @type do |reference, &item_definition|
          register reference, item_definition
        end
      end
    end

    def parser
      ParserGenerator.new(generate_entity, @attributes).generate
    end
  end

  # These falsely triggers on instance variables in the generated class.
  # :reek:TooManyInstanceVariables
  # :reek:InstanceVariableAssumption
  class ParserGenerator
    def initialize entity_klass, attributes
      @entity_klass = entity_klass
      @attributes = attributes
      @fields = attribute_fields
      @parser = Class.new { attr_reader :controls, :roles }
    end

    def generate
      generate_initialize
      generate_entity @entity_klass
      generate_all_fields
      @parser
    end

    private

    def generate_all_fields
      @attributes.each { |attribute| generate_field attribute }
    end

    def generate_field attribute
      if attribute[:type] == :description
        generate_block_field attribute
      else
        generate_plain_field attribute
      end
    end

    def generate_block_field attribute
      field = attribute[:name]
      @parser.define_method field do |&field_value|
        @attributes[field] = field_value
      end
    end

    def generate_plain_field attribute
      field = attribute[:name]
      @parser.define_method field do |field_value|
        @attributes[field] = field_value
      end
    end

    def generate_entity entity_klass
      @parser.define_method :to_entity do
        entity_klass.new(reference: @item_reference, **@attributes)
      end
    end

    def generate_initialize
      @parser.define_method :initialize do |item_reference, reference_collection|
        @item_reference = item_reference
        @reference_collection = reference_collection
        @attributes = {}

        @roles = reference_collection[:roles]
        @controls = reference_collection[:controls]
      end
    end

    def attribute_fields
      @attributes.map { |attribute| attribute[:name] }
    end
  end
end
