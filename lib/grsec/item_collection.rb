# frozen_string_literal: true

module Grsec
  # :reek:TooManyInstanceVariables
  class ItemCollection
    attr_reader :references, :items

    def initialize reference_class:, parser_class:
      @references = References.new
      @raw_items = {}

      @reference_class = reference_class
      @parser_class = parser_class
    end

    def parse references
      @items = @raw_items.each_pair.map do |reference, item_definition|
        parser = @parser_class.new reference, **references
        parser.instance_eval(&item_definition)
        parser.to_entity.tap { |item| @references.associate reference, item }
      end
    end

    def register reference, item_definition
      reference_id = @reference_class.new(**reference)
      @references.register reference_id
      @raw_items[reference_id] = item_definition
    end
  end
end
