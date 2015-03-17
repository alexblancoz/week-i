class ScoresController < ApplicationController

  layout false

  def index

  end

  def modal

  end

  def generate
    @users = User.base.base_scores.with_group_users.with_groups.with_scores.with_course_professor_users.with_course_professors.with_professors.with_courses.group_by_score#.order_by_professor
    respond_to do |format|
      format.xlsx
    end
  end

end
