class Api::Course < Course

  module Json
    LIST = { }
    SHOW = { only: [:id, :key, :name, :semester], methods: [:professors] }
  end

end