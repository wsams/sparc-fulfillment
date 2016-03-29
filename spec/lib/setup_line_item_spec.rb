require 'rails_helper'

RSpec.describe SetupLineItem do
  describe '#create_arm' do
    it 'should create a new line item' do
      protocol = build_stubbed(:protocol)
      service = create(:service)
      arm = create(:arm, protocol: protocol)
      arm_creator = SetupLineItem.new(arm, [service])

      service = arm_creator.create_line_item

      expect(line_item.protocol_id).to eq(arm.protocol_id)
    end
  end
end
