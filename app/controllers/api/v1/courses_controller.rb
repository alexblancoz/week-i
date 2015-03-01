class Api::V1::CoursesController < Api::ApiController

  before_action :assert_user
  before_action :assert_course, only: [:update, :destroy]

  # POST /api/courses/list.json
  def list
    @courses = paginate(Api::Course.base) if @user.identity == Api::User::Identity::USER
    @courses = paginate(Api::Course.base) if @user.identity == Api::User::Identity::ADMINISTRATOR
    render json: @courses.as_json(Api::Course::Json::LIST)
  end

  # POST /api/courses/taken.json
  def taken
    @courses = paginate(Api::Course.base.base_professors.base_course_professor_users.with_course_professors.with_professors.with_course_professor_users(@user.id).filter_by_user(@user.id).order(:semester))
    render json: @courses.as_json(Api::Course::Json::LIST)
  end

  # POST /api/courses/not_taken.json
  def not_taken
    @courses = paginate(Api::Course.base.with_course_professors.with_professors.with_course_professor_users(@user.id).filter_by_no_user.order(:semester))
    render json: @courses.as_json(Api::Course::Json::LIST)
  end

  # POST /api/courses/show.json
  def show
    @course = Api::Course.base.base_users.with_users.filter_by_user(@user.id).first
    render json: @course.as_json(Api::Course::Json::SHOW)
  end

  # POST /api/courses/create.json
  def create
    @course = Api::Course.new(course_params)
    @course.owner_id = @user.id
    if @course.save
      render json: @course.as_json(Api::Course::Json::SHOW)
    else
      render_errors(:unprocessable_entity, @course.errors)
    end
  end

  # POST /api/courses/update.json
  def update
    if @course.nil?
      render json: { error: "Couldn't find course" }
    else
      if @course.update(course_params)
        render json: @course.as_json(Api::Course::Json::SHOW)
      else
        render_errors(:unprocessable_entity, @course.errors);
      end
    end
  end

  # POST /api/courses/destroy.json
  def destroy
    if @course.destroy
      render json: @course.as_json(Api::Course::Json::SHOW)
    else
      render_error(:expectation_failed, "Course couldn't be deleted.")
    end
  end

  # POST /api/courses/add_professor.json
  def add_professor
    failed = false
    @course_professor = Api::CourseProfessor.base.filter_by_id(params[:id]).first
    if @course_professor.nil?
      failed = true
    else
      @course_professor_user = CourseProfessorUser.new
      @course_professor_user.user_id = @user.id
      @course_professor_user.course_professor_id = @course_professor.id
      failed = !@course_professor_user.save
    end
    if failed
      render_error(:expectation_failed, 'Hubo un error agregando la materia')
    else
      render json: @course_professor
    end
  end

  # POST /api/courses/destroy_professor.json
  def destroy_professor
    failed = false
    @course_professor_user = Api::CourseProfessorUser.base.filter_by_id(params[:id]).first
    if @course_professor_user.nil?
      failed = true
    else
      if @course_professor_user.user_id != @user.id
        ban_user
        return
      end
      failed = !@course_professor_user.destroy
    end
    if failed
      render_error(:expectation_failed, 'Hubo un error quitando la materia')
    else
      render json: @course_professor_user
    end
  end

  # POST /api/courses/professors.json
  def professors
    @professors = Api::Professor.base.base_course_professor.with_course_professors.filter_by_course(params[:id])
    render json: @professors.as_json(Api::Professor::Json::COURSE)
  end

  protected

  def assert_course
    @course = Course.filter_by_id(params[:id]).first
  end

  def course_params
    params.permit(:name)
  end

end
