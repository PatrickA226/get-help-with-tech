class Support::NewUserSchoolForm
  include ActiveModel::Model

  attr_accessor :user, :name_or_urn

  def initialize(user:, name_or_urn: nil)
    @user = user
    @name_or_urn = name_or_urn
  end

  def matching_schools
    School.includes(:responsible_body)
          .where('urn = ? OR name ILIKE(?)', @name_or_urn.to_i, "%#{@name_or_urn}%")
          .order(:name)
  end
end