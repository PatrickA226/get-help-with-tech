class DeliveryAddress < ApplicationRecord
  belongs_to :school

  before_validation :generate_computacenter_identifier

  after_update :maybe_generate_user_changes

  def computacenter_identifier_otherwise_urn
    computacenter_identifier || school.urn
  end

private

  def maybe_generate_user_changes
    school.send(:maybe_generate_user_changes)
  end

  def generate_computacenter_identifier
    if school.is_further_education?
      self.computacenter_identifier = next_computacenter_identifier
    end
  end

  def next_computacenter_identifier
    last_delivery_address = school.delivery_addresses.order(computacenter_identifier: :desc).first

    if last_delivery_address
      last_delivery_address.computacenter_identifier.next
    else
      "#{school.ukprn}-A"
    end
  end
end
