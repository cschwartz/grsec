# frozen_string_literal: true

module Grsec
  ControlsCollection = define_type :control do
    identified_by :group, :id
    attribute name: :accountable, type: reference(:role)
    attribute name: :state, type: options(:inactive, :active, :archived)
    attribute name: :statement, type: :description
  end

  class ControlRenderer
    def initialize control
      @control = control
    end

    def render
      statement = @control.statement
      p instance_eval(&statement)
    end

    def accountable
      @control.accountable.to_s
    end
  end
end
