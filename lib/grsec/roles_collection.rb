# frozen_string_literal: true

module Grsec
  RoleReference = Struct.new :id, keyword_init: true do
    def to_s
      id.to_s
    end

    def to_sym
      to_s.to_sym
    end
  end

  class RolesCollection < ItemsCollection
    attr_reader :references

    def initialize
      super reference_class: RoleReference, parser_class: RoleParser
    end

    def role reference, &item_definition
      register reference, item_definition
    end
  end

  class RoleParser
    attr_reader :roles, :controls

    def initialize reference, references
      @reference = reference

      @roles = references[:roles]
      @controls = references[:controls]

      @title = nil
    end

    def title role_title
      @title = role_title
    end

    def to_entity
      Role.new @reference, @title
    end
  end

  Role = Struct.new :id, :title
end
