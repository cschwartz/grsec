# frozen_string_literal: true

module Grsec
  def self.generate_references reference_items
    Struct.new(*reference_items, keyword_init: true) do
      def to_s
        members.map { |item| self[item] }
               .join("_")
      end

      def to_sym
        to_s.to_sym
      end
    end
  end

  class References
    def initialize
      @references = {}
    end

    def register reference
      @references[reference] = nil
      define_singleton_method(reference.to_sym) { reference }
    end

    def associate reference, target
      @references[reference] = target
    end

    def resolve reference
      @references[reference]
    end
  end
end
