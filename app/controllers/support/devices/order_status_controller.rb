class Support::Devices::OrderStatusController < Support::BaseController
  before_action :set_school

  def edit
    @form = Support::EnableOrdersForm.new(existing_params.merge(enable_orders_form_params))
  end

  def update
    @form = Support::EnableOrdersForm.new(enable_orders_form_params)
    if @form.valid?
      ActiveRecord::Base.transaction do
        allocation = device_allocation
        # we only take the cap from the user if they chose specific circumstances
        # for both other states, we need to infer a new cap from the chosen state
        allocation.cap = allocation.cap_implied_by_order_state(order_state: @form.order_state, given_cap: @form.cap)
        allocation.save!
        @school.update!(order_state: @form.order_state)
      end
      flash[:success] = t(:success, scope: %i[support order_status update])
      redirect_to support_devices_school_path(urn: @school.urn)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def set_school
    @school = School.find_by_urn(params[:school_urn])
  end

  def existing_params
    {
      order_state: @school.order_state,
      cap: device_allocation.cap,
    }
  end

  def device_allocation
    SchoolDeviceAllocation.find_or_initialize_by(school: @school, device_type: 'std_device')
  end

  def enable_orders_form_params(opts = params)
    opts.fetch(:support_enable_orders_form, {}).permit(:order_state, :cap)
  end
end
