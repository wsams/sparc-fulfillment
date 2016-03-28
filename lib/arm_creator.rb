class ArmCreator
  def initialize(arm, services)
    @arm = arm
    @services = services || []
  end

  def build_line_item
    @services.each do |service|
      line_item = LineItem.new(protocol_id: @arm.protocol_id, arm_id: @arm.id, service_id: service, subject_count: @arm.subject_count)
      save_and_create_dependents(line_item)
    end
  end

  def create_arm
    build_line_item
  end

  private

  def save_and_create_dependents(line_item)
    importer = LineItemVisitsImporter.new(line_item)
    importer.save_and_create_dependents
  end
end
