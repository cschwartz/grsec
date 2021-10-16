# frozen_string_literal: true

class String
  def strip_heredoc
    gsub(/^#{scan(/^[ \t]*(?=\S)/).min}/, "")
  end
end

# 1. Iterate over all roles and build
#  a. List of role references which can later be used to lazyly resolve roles
#  b. Role parsers
# -- do the same for all other entity types --
# 2. Parse roles and assign parsed roles to list of role references
# -- do the same for all other entity types
# 3. Render roles
# -- do the same for all other entity types

module Grsec
  ControlReference = Struct.new :group, :id, keyword_init: true do
    def to_s
      "#{group}_#{id}"
    end

    def to_sym
      to_s.to_sym
    end
  end

  class ControlCollection < ItemCollection
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
