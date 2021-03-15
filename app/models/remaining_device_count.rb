class RemainingDeviceCount < ApplicationRecord
  include ExportableAsCsv

  validates :date_of_count, :remaining_from_devolved_schools, :remaining_from_managed_schools, :total_remaining, presence: true

  before_validation :calculate_total

  def self.exportable_attributes
    {
      date_of_count: 'Date',
      total_remaining: 'Total remaining',
      remaining_from_devolved_schools: 'Remaining from devolved schools',
      remaining_from_managed_schools: 'Remaining from managed schools',
    }
  end

private
  
  def calculate_total
    self.total_remaining = remaining_from_devolved_schools + remaining_from_managed_schools
  end
end
