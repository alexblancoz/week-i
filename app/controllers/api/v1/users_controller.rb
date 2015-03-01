class Api::V1::UsersController < Api::ApiController

  before_action :assert_user, except: [:login, :create, :majors, :campuses]

  # POST /api/v1/users/login.json
  def login
    @user = Api::User.authenticate(params[:enrollment], params[:password])
    if @user
      if @user.active
        render json: @user.token.as_json(Api::Token::Json::SHOW)
      else
        render_error(:unauthorized, "Cuenta baneada. Contacta un administrador")
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
      Api::User.authenticate(@user.enrollment, @user.password)
      render json: @user.token.as_json(Api::Token::Json::SHOW)
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

  protected

  def user_params
    params.permit(:name, :last_names, :password, :major, :campus, :enrollment, :password_confirmation)
  end

end
