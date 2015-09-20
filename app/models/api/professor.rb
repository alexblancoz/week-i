class Api::Professor < Professor

  module Json
    LIST = { only: [:id, :name, :last_names] }
    SHOW = { only: [:id, :name, :last_names] }
    COURSE = { only: [:name, :last_names, :course_professor_id] }
  end

end