class ScoresController < ApplicationController

  layout false

  def index

  end

  def modal

  end

  def generate_users
    @users = User.base.base_scores.base_scores_all.with_group_users.with_groups.with_scores.group_by_score
    respond_to do |format|
      format.xlsx
    end
  end

  def generate_groups
    #TODO generate in a single query without view filtering (see view) (Really Hard)
    #@users = User.base.base_scores.with_group_users.with_groups.with_scores.with_course_professor_users.with_course_professors.with_professors.with_courses.group_by_score#.order_by_professor
    @professors = Professor.base.base_course_professors.base_course_professor_users.base_courses.with_course_professors.with_course_professor_users.with_courses.order(:id)
    @users = User.base.base_scores.with_group_users.with_groups.with_scores.group_by_score.filter_by_identity(User::Identity::USER)
    respond_to do |format|
      format.xlsx
    end
  end

end
