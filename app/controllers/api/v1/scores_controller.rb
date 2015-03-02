class Api::V1::ScoresController < Api::ApiController

  before_action :assert_teacher

  # POST /api/scores/scored_groups.json
  def scored_groups
    @scores = paginate(Api::Score.base.base_users.base_groups.with_groups(@user.id).with_users.filter_by_score)
    render json: @scores.as_json(Api::Score::Json::LIST)
  end

  def create
    @score = Api::Score.new(score_params)
    @score.user_id = @user.id
    if @score.save
      render json: @score.as_json(Api::Score::Json::SHOW)
    else
      render_errors(:unprocessable_entity, @score.errors)
    end
  end

  # POST /api/groups/non_scored_groups.json
  def non_scored_groups
    @scores = paginate(Api::Score.base.base_users.base_groups.with_groups(@user.id).with_users)
    render json: @scores.as_json(Api::Score::Json::LIST)
  end

  protected

  def score_params
    params.permit(:innovation_score, :creativity_score, :functionality_score, :business_model_score, :modeling_tools_score, :observations, :user_id, :group_id)
  end

end
