# frozen_string_literal: true

module Grsec
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
