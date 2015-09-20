class Api::V1::GroupsController < Api::ApiController

  before_action :assert_group, only: [:update, :destroy, :add_membership]
  before_action :assert_user
  before_action :assert_group_owner, only: [:update, :destroy]

  # POST /api/groups/list.json
  def list
    @groups = paginate(Api::Group.base.base_users.with_users)
    render json: @groups.as_json(Api::Group::Json::LIST)
  end

  # POST /api/groups/show.json
  def show
    @group = Api::Group.base.base_users.base_group_users.with_users.with_group_users(@user.id).filter_by_id(params[:id]).first
    render json: @group.as_json(Api::Group::Json::SHOW)
  end

  # POST /api/groups/create.json
  def create
    @group = Api::Group.new(group_params)
    @group.owner_id = @user.id
    if @group.save
      render json: @group.as_json(Api::Group::Json::SHOW)
    else
      render_errors(:unprocessable_entity, @group.errors)
    end
  end

  # POST /api/groups/update.json
  def update
    if @group.nil?
      render_error(:expectation_failed, 'No se encontro el grupo')
    else
      if @group.update(group_params)
        render json: @group.as_json(Api::Group::Json::SHOW)
      else
        render_errors(:unprocessable_entity, @group.errors);
      end
    end
  end

  # POST /api/groups/destroy.json
  def destroy
    if @group.destroy
      render json: @group.as_json(Api::Group::Json::SHOW)
    else
      render_error(:expectation_failed, "Group couldn't be deleted.")
    end
  end

  # POST /api/groups/add_membership.json
  def add_membership
    @group_user = GroupUser.new
    @group_user.user_id = @user.id
    @group_user.group_id = params[:id]
    if @group_user.save
      render json: @group_user
    else
      render_errors(:unprocessable_entity, @group_user.errors);
    end
  end

  # POST /api/groups/destroy_membership.json
  def destroy_membership
    @group_user = GroupUser.base.filter_by_user(@user.id).first
    if @group_user.destroy
      render json: @group_user
    else
      render_errors(:expectation_failed, "No se pudo dejar el grupo.")
    end
  end

  # POST /api/groups/accept_membership.json
  def accept_membership
    @group_user = GroupUser.base.filter_by_user(params[:id]).first
    @group_user.status = GroupUser::Status::MEMBER
    @group = @group_user.group
    ban_user and return if @group.owner_id != @user.id
    if @group_user.save
      render json: @group_user
    else
      render_errors(:unprocessable_entity, @group_user.errors);
    end
  end

  protected

  def assert_group
    @group = Group.filter_by_id(params[:id]).first
  end

  def assert_group_owner
    ban_user if @group.owner_id != @user.id
  end

  def group_params
    params.permit(:name)
  end

end
