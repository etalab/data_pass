class Admin::UsersWithRolesController < AdminController
  def index
    @search_engine = User.with_roles.includes(:organizations).ransack(params[:search_query])
    @search_engine.sorts = 'created_at desc' if @search_engine.sorts.empty?

    @users = @search_engine.result(distinct: true).page(params[:page]).per(50)
  end
end
