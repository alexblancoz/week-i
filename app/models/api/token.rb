class Api::Token < Token

  module Json
    SHOW = { only: [:token, :secret], methods: :user_identity }
  end

end