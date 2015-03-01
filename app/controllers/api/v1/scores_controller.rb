class Api::V1::ScoresController < Api::ApiController

  before_action :assert_user

  # POST /api/scores/scored_groups.json
  def scored_groups
    @scores = paginate(Api::Score.base.base_users.base_groups.with_groups(@user.id).with_users.filter_by_score)
    render json: @scores.as_json(Api::Score::Json::LIST)
  end

  # POST /api/groups/non_scored_groups.json
  def non_scored_groups
    @scores = paginate(Api::Score.base.base_users.base_groups.with_groups(@user.id).with_users)
    render json: @scores.as_json(Api::Score::Json::LIST)
  end

end
