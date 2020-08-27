require 'open-uri'
require 'csv'

class GetInformationAboutSchools
  EDUBASE_URL = 'https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/'.freeze

  def self.trusts_entries
    gias_csv = URI.parse(groups_url).read.force_encoding(Encoding::ISO8859_1)
    CSV.parse(gias_csv, headers: true).select { |row|
      row['Group Type'].in?(['Single-academy trust', 'Multi-academy trust']) && row['Group Status'] == 'Open'
    }.map(&:to_h)
  end

  def self.schools(&block)
    file = Tempfile.new
    fetch_latest_edubase_file(file)
    SchoolDataFile.new(file.path).schools(&block)
  ensure
    file.close
    file.unlink
  end

  def self.contacts(&block)
    file = Tempfile.new
    fetch_contacts_file(file)
    ContactDataFile.new(file.path).contacts(&block)
  ensure
    file.close
    file.unlink
  end

  def self.fetch_latest_edubase_file(file)
    RemoteFile.download(schools_url, file)
  end

  def self.fetch_contacts_file(file)
    RemoteFile.download(school_contacts_url, file)
  end

  def self.groups_url
    "#{EDUBASE_URL}allgroupsdata.csv"
  end

  def self.schools_url(date: Time.zone.now)
    "#{EDUBASE_URL}edubasealldata#{date.strftime('%Y%m%d')}.csv"
  end

  def self.school_contacts_url
    # this is a private file
    ENV.fetch('CONTACTS_FILE_URL')
  end
end
