class Api::Score < Score

  module Json
    LIST = { methods: [:score] }
    SHOW = {}
  end

end