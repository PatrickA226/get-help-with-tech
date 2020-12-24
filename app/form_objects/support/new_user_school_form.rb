class Support::NewUserSchoolForm
  include ActiveModel::Model

  attr_accessor :user, :name_or_urn

  def initialize(user:, name_or_urn: nil)
    @user = user
    @name_or_urn = name_or_urn
  end

  def matching_schools
    School
      .matching_name_or_urn(@name_or_urn)
      .includes(:responsible_body)
      .order(:name)
  end
end
