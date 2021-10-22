# frozen_string_literal: true

module Grsec
  RoleReference = generate_references [:id]

  RoleType = define_type { attribute name: :title, type: String }

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
