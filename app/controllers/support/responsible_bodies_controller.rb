class Support::ResponsibleBodiesController < Support::BaseController
  def index
    @responsible_bodies = ResponsibleBody
      .select('responsible_bodies.*')
      .excluding_department_for_education
      .with_users_who_have_signed_in_at_least_once
      .with_user_count
      .with_completed_preorder_info_count
      .order('type asc, name asc')
  end

  def show
    @responsible_body = ResponsibleBody.find(params[:id])
    @users = @responsible_body.users.order('last_signed_in_at desc nulls last, updated_at desc')
    @schools = @responsible_body
      .schools
      .includes(:device_allocations, :preorder_information)
      .order(name: :asc)
  end
end