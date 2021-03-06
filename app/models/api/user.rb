class Api::User < User

  module Json
    SHOW = { only: [:id, :name, :last_names, :email, :identity] }
  end

  def token
    @token ||= ->{
      token = Token.filter_by_user(self.id).first
      if token.nil?
        token = Token.generate(self.id)
        token = nil unless token.save
      end
      token
    }.call
  end

end