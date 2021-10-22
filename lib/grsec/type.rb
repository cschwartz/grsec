# frozen_string_literal: true

module Grsec
  def self.define_type &block
    Type.new
        .tap { |type| type.instance_eval(&block) }
        .generate
  end

  class Type
    def initialize
      @attributes = []
    end

    def attribute name:, **_type
      @attributes << {name: name}
    end

    def options *values
      {type: :options, options: values}
    end

    def reference target
      {type: :reference, target: target}
    end

    def string
      {type: :string}
    end

    def generate
    end
  end
end
