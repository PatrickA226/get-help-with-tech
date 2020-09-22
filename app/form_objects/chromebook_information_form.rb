class ChromebookInformationForm
  include ActiveModel::Model

  attr_accessor :school, :will_need_chromebooks, :school_or_rb_domain, :recovery_email_address

  validates :will_need_chromebooks, presence: true

  with_options if: :will_need_chromebooks? do |condition|
    condition.validates :recovery_email_address,
                        presence: true,
                        email_address: true

    condition.validates :school_or_rb_domain,
                        presence: true,
                        gsuite_domain: { message: I18n.t('activemodel.errors.models.chromebook_information_form.attributes.school_or_rb_domain.invalid_domain') }
    condition.validate :recovery_email_address_cannot_be_same_domain_as_school_or_rb
  end

  def will_need_chromebooks?
    will_need_chromebooks == 'yes'
  end

  def recovery_email_address_cannot_be_same_domain_as_school_or_rb
    if recovery_email_address&.ends_with?(school_or_rb_domain)
      errors.add(:recovery_email_address, :cannot_be_same_domain_as_school_or_rb)
    end
  end
end
