class Api::V1::ScoresController < ApplicationController

  before_action :assert_user
  before_action :assert_course, only: [:update, :destroy]

  # POST /api/scores/scored_groups.json
  def scored
    @scores = paginate(Api::Group.base.base_users.base_scores.with_users.with_scores(@user.id))
    render json: @scores.as_json(Api::Score::Json::LIST)
  end

  # POST /api/groups/non_scored_groups.json
  def non_scored_groups
    @groups = paginate(Api::Group.base.base_users.base_scores.with_users)
    render json: @scores.as_json(Api::Score::Json::LIST)
  end

end
