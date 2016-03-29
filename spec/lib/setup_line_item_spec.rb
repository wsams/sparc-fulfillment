require 'rails_helper'

RSpec.describe SetupLineItem do
  describe '#create_arm' do
    it 'should create a line item for the service' do
      protocol = create(:protocol)
      service = create(:service)
      arm = create(:arm, protocol: protocol)
      setup_line_item = SetupLineItem.new(arm, [service])

      service = setup_line_item.create_line_item

      expect(service.first.line_items.first.service_id).to eq(service.first.id)
    end

    it 'should have the arm_id of the new arm' do
      protocol = create(:protocol)
      service = create(:service)
      arm = create(:arm, protocol: protocol)
      setup_line_item = SetupLineItem.new(arm, [service])

      service = setup_line_item.create_line_item

      expect(service.first.line_items.first.arm_id).to eq(arm.id)
    end

    it 'should have the protocol id of the new arm' do
      protocol = create(:protocol)
      service = create(:service)
      arm = create(:arm, protocol: protocol)
      setup_line_item = SetupLineItem.new(arm, [service])

      service = setup_line_item.create_line_item

      expect(service.first.line_items.first.protocol_id).to eq(arm.protocol_id)
    end

    it 'should have the same subject count as the new arm' do
      protocol = create(:protocol)
      service = create(:service)
      arm = create(:arm, protocol: protocol)
      setup_line_item = SetupLineItem.new(arm, [service])

      service = setup_line_item.create_line_item

      expect(service.first.line_items.first.subject_count).to eq(arm.subject_count)
    end
  end
end
