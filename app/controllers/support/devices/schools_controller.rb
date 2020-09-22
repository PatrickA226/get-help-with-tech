class Support::Devices::SchoolsController < Support::BaseController
  def index; end

  def show
    @school = School.find_by!(urn: params[:urn])
    @users = @school.users
    @contacts = @school.contacts
  end

  def confirm_invitation
    @school = School.find_by!(urn: params[:school_urn])
    @school_contact = @school.preorder_information&.school_contact
    if @school_contact.nil?
      flash[:warning] = I18n.t('support.schools.invite.no_school_contact', name: @school.name)
      redirect_to support_devices_school_path(@school)
    end
  end

  def invite
    school = School.find_by!(urn: params[:school_urn])
    success = school.invite_school_contact
    if success
      flash[:success] = I18n.t('support.schools.invite.success', name: school.name)
    else
      flash[:warning] = I18n.t('support.schools.invite.failure', name: school.name)
    end
    redirect_to support_devices_responsible_body_path(school.responsible_body)
  end
end
