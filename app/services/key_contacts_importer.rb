class KeyContactsImporter
  attr_reader :datasource

  def initialize(contact_datasource)
    @datasource = contact_datasource
  end

  def import_contacts
    datasource.contacts do |contact_data|
      rb = ResponsibleBody.find(contact_data[:id])

      contact = find_or_add_user!(rb, contact_data)

      rb.key_contact = contact
      rb.in_devices_pilot = true
      rb.save!

      InviteResponsibleBodyUserMailer.with(user: contact,
                                           responsible_body: rb).nominate_contacts_email.deliver_later!
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      Rails.logger.error(e.message)
    end
  end

  def self.import_from_url(url)
    file = Tempfile.new
    RemoteFile.download(url, file)
    new(KeyContactDataFile.new(file.path)).import_contacts
  ensure
    file.close
    file.unlink
  end

private

  def find_or_add_user!(rb, contact_data)
    User.find_or_create_by(email_address: contact_data[:email_address]) do |u|
      u.full_name = full_name(contact_data)
      u.telephone = contact_data[:telephone]
      u.responsible_body = rb
    end
  end

  def full_name(contact_data)
    contact_data[:full_name] || contact_data[:email_address]
  end
end
