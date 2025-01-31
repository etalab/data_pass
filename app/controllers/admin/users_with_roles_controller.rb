class Admin::UsersWithRolesController < AdminController
  def index
    @search_engine = User.with_roles.includes(:organizations).ransack(params[:search_query])
    @search_engine.sorts = 'created_at desc' if @search_engine.sorts.empty?

    @users = @search_engine.result(distinct: true).page(params[:page]).per(50)
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])

    render 'new'
  end

  def create
    @user = User.find_by(email: user_params[:email]) || User.new(user_params)

    if @user.new_record?
      error_message(title: t('.not_found', user_email: user_params[:email]))

      render 'new', status: :unprocessable_entity
    else
      update
    end
  end

  def update
    @user ||= User.find(params[:id])

    organizer = Admin::UpdateUserRoles.call(admin: current_user, user: @user, roles: user_roles_param)

    if organizer.success?
      success_message(title: t('.success', user_email: @user.email))

      redirect_to admin_users_with_roles_path
    else
      error_message(title: t('.error'), message: organizer.error)
    end
  end

  private

  def user_roles_param
    roles = user_params[:roles] || ''
    roles.split("\n").map(&:strip)
  end

  def user_params
    params.expect(user: %i[email roles])
  end
end
