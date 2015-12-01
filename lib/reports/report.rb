class Report
  include ActionView::Helpers::NumberHelper

  # Required dependency for ActiveModel::Errors
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  attr_accessor :title, :start_date, :end_date

  attr_reader :errors

  def initialize(attributes = Hash.new)
    @attributes = attributes
  end

  def valid?
    self.class::VALIDATES_PRESENCE_OF.each{ |validates| errors.add(validates, "must not be blank") if @attributes[validates].blank? }
    self.class::VALIDATES_NUMERICALITY_OF.each{ |validates| errors.add(validates, "must be a number") unless @attributes[validates].is_a?(Numeric) }

    errors.empty?
  end

  def kind
    self.class
  end

  private

  def format_date(date)
    if date.present?
      date.strftime("%m/%d/%Y")
    else
      ''
    end
  end

  def display_cost(cost)
    if cost
      dollars = (cost / 100.0) rescue nil
      dollar, cent = dollars.to_s.split('.')
      dollars_formatted = "#{dollar}.#{cent[0..1]}".to_f

      number_to_currency(dollars_formatted, seperator: ",", unit: "")

    else
      "N/A"
    end
  end
end
