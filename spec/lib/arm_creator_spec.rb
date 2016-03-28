require 'rails_helper'

RSpec.describe ArmCreator do
  describe '#create_arm' do
    it 'should create a new line item' do
      service = create(:service)
      arm = create(:arm)
      arm_creator = ArmCreator.new(arm, [service])

      result = arm_creator.create_arm

      binding.pry
    end
  end
end
