class Support::Devices::UsersController < Support::BaseController
  def edit
    @school = School.find_by(urn: params[:school_urn])
    @user = present(@school.users.find(params[:id]))
  end

  def update
    @school = School.find_by(urn: params[:school_urn])
    @user = @school.users.find(params[:id])

    if @user.update(user_params)
      flash[:success] = 'User has been updated'
      redirect_to support_devices_school_path(urn: @school.urn)
    else
      @user = present(@user)
      render :edit, status: :unprocessable_entity
    end
  end

private

  def present(user)
    SchoolUserPresenter.new(user)
  end

  def user_params
    params.require(:user).permit(:full_name, :email_address, :telephone, :orders_devices)
  end
end
