class Api::V1::UsersController < Api::ApiController

  before_action :assert_user, except: [:list, :login, :create, :majors, :campuses]
  before_action :assert_administrator, only: [:list]

  def list
    @users = User.base.base_scores.with_group_users.with_groups.with_scores.group_by_score
    render json: @users.as_json(Api::User::Json::LIST)
  end

  # POST /api/v1/users/login.json
  def login
    if params[:enrollment].upcase =~ /^A*[0-9]/
      enrollment = params[:enrollment].upcase
    else
      enrollment = params[:enrollment]
    end
    @user = Api::User.authenticate(enrollment, params[:password])
    if @user
      unless @user.verified
        render_error(:unauthorized, "Cuenta no verificada.")
      else
        if @user.active
          render json: @user.token.as_json(Api::Token::Json::SHOW)
        else
          render_error(:unauthorized, "Cuenta baneada. Contacta un administrador")
        end
      end

    else
      render_error(:unauthorized, "Credenciales incorrectas")
    end
  end

  # POST /api/v1/users/show.json
  def show
    render json: @user.as_json(Api::User::Json::SHOW)
  end

  # POST /api/v1/users/create.json
  def create
    @user = Api::User.new(user_params)
    @user.identity = Api::User::Identity::USER
    if @user.save
      #Api::User.authenticate(@user.enrollment, @user.password)
      render json: @user.as_json(Api::User::Json::SHOW)
    else
      render_errors(:unprocessable_entity, @user.errors)
    end
  end

  # POST /api/v1/users/update.json
  def update
    if @user.nil?
      render json: { error: "Couldn't find user" }
    else
      @user.update(user_params)
      if @user.save
        render json: @user.as_json(Api::User::Json::SHOW)
      else
        render_errors(:unprocessable_entity, @user.errors);
      end
    end
  end

  # POST /api/v1/users/update_password.json
  def update_password
    @user.update(params.permit(:password, :password_confirmation))
    if @user.save
      render json: @user.as_json(Api::User::Json::SHOW)
    else
      render_errors(:unprocessable_entity, @user.errors)
    end
  end

  # POST /api/v1/users/majors.json
  def dashboard
    render json: Api::User::Identity::LIST[@user.identity][:dashboard]
  end

  # POST /api/v1/users/majors.json
  def majors
    render json: Api::User::Major.object_values
  end

  # POST /api/v1/users/campuses.json
  def campuses
    render json: Api::User::Campus.object_values
  end

  # POST /api/v1/users/identities.json
  def identities
    render json: Api::User::Identity.object_values
  end

  protected

  def user_params
    params.permit(:name, :last_names, :password, :major, :campus, :enrollment, :password_confirmation)
  end

end
