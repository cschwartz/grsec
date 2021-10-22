# frozen_string_literal: true

module Grsec
  RolesCollection = define_type :role do
    identified_by :id
    attribute name: :title, type: :string
  end
end
