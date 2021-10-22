# frozen_string_literal: true

module Grsec
  ControlReference = generate_references %i[group id]

  ControlType = define_type do
    attribute name: :accountable, type: reference(RoleType)
    attribute name: :state, type: options(:inactive, :active, :archived)
    attribute name: :statement, type: :description
  end

  class ControlsCollection < ItemsCollection
    def initialize
      super reference_class: ControlReference, parser_class: ControlParser
    end

    def control reference, &item_definition
      register reference, item_definition
    end

    def controls
      items
    end
  end

  # :reek:TooManyInstanceVariables
  class ControlParser
    attr_reader :roles, :controls

    def initialize reference, references
      @reference = reference

      @roles = references[:roles]
      @controls = references[:controls]

      @accountable = nil
      @state = nil
      @statement = nil
    end

    def accountable control_accountable
      @accountable = control_accountable
    end

    def state control_state
      @state = control_state
    end

    def statement &control_statement
      @statement = control_statement
    end

    def to_entity
      Control.new @reference, @state, @accountable, @statement
    end
  end

  Control = Struct.new :reference, :state, :accountable, :statement

  class ControlRenderer
    def initialize control
      @control = control
    end

    def render
      statement = @control.statement
      result = instance_eval(&statement)
      p result
    end

    def accountable
      @control.accountable.to_s
    end
  end
end
