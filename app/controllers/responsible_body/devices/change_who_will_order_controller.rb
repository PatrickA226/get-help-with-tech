class ResponsibleBody::Devices::ChangeWhoWillOrderController < ResponsibleBody::BaseController
  before_action :set_school

  def edit
    @form = ResponsibleBody::Devices::WhoWillOrderForm.new(
      who_will_order: who_will_order,
    )
  end

  def update
    authorize ResponsibleBody::Devices::WhoWillOrderForm, policy_class: ResponsibleBody::BasePolicy

    @form = ResponsibleBody::Devices::WhoWillOrderForm.new(who_will_order_params)
    if @form.valid?
      @school.preorder_information.change_who_will_order_devices!(@form.who_will_order)

      flash[:success] = I18n.t(:success, scope: %i[responsible_body devices who_will_order update])
      redirect_to responsible_body_devices_school_path(@school.urn)
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActionController::ParameterMissing
    @form = ResponsibleBody::Devices::WhoWillOrderForm.new
    render :edit, status: :unprocessable_entity
  end

private

  def set_school
    @school = @responsible_body.schools.where_urn_or_ukprn(params[:school_urn]).first!
  end

  def who_will_order
    @school.preorder_information.who_will_order_devices
  end

  def who_will_order_params
    params.require(:responsible_body_devices_who_will_order_form).permit(:who_will_order)
  end
end
