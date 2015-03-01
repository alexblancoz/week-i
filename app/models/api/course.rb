class Api::Course < Course

  module Json
    LIST = { only: [:id, :key, :name, :semester] }
    SHOW = { only: [:id, :key, :name, :semester] }
  end

end