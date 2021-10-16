# frozen_string_literal: true

require "spec_helper"

RSpec.describe Grsec::ControlCollection do
  subject(:control_collection) { described_class.new }

  it "generates references from controls passed via block" do
    control_collection.instance_eval { control group: "TEST", id: 1 }
    expect(control_collection.references).to respond_to(:TEST_1)
  end

  it "generate correct number of controls after parsing" do
    control_collection.instance_eval do
      control(group: "TEST", id: 1) { state :active }
      control(group: "TEST", id: 2) { state :active }
    end
    control_collection.parse({roles: nil, controls: nil})

    expect(control_collection.controls.size).to eq(2)
  end

  it "generate control with the apropriate properties" do
    control_collection.instance_eval { control(group: "TEST", id: 1) { state :active } }
    control_collection.parse({roles: nil, controls: nil})

    expect(control_collection.controls.first).to have_attributes(
      state: :active,
      reference: control_collection.references.TEST_1
    )
  end
end
