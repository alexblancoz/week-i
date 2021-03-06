class Api::V1::ProfessorsController < Api::ApiController

  before_action :assert_user
  before_action :assert_professor, only: [:update, :destroy]

  # POST /api/groups/list.json
  def list
    @professors = Professor.all
    render json: @professors.as_json(Api::Professor::Json::LIST)
  end

  def create
    @professor = Api::Professor.new(professor_params)
    if @professor.save
      render json: @professor.as_json(Api::Professor::Json::SHOW)
    else
      render_errors(:unprocessable_entity, @professor.errors)
    end
  end

  def destroy
    if @professor.destroy
      render json: @professor.as_json(Api::Professor::Json::SHOW)
    else
      render_error(:expectation_failed, "El profesor no pudo ser eliminado.")
    end
  end

  protected

  def assert_professor
    @professor = Professor.filter_by_id(params[:id]).first
  end

  def professor_params
    params.permit(:name, :last_names)
  end

end
