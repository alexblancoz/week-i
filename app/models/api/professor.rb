class Api::Professor < Professor

  module Json
    LIST = { only: [:name, :last_names] }
    COURSE = { only: [:name, :last_names, :course_professor_id] }
  end

end