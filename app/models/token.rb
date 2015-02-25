class Token < ActiveRecord::Base

  # concerns
  include Tokenable

  # scopes
  scope :base, ->{ select('tokens.id, tokens.user_id, tokens.token, tokens.secret, tokens.expires_at, tokens.updated_at, tokens.created_at') }
  scope :filter_by_token, ->(token, secret){ where('tokens.token = ? AND tokens.secret = ?', token, secret) }
  scope :filter_by_id, ->(id){ where('tokens.id = ?', id) }

  # methods
  def user
    @user ||= User.find_by_id(self.user_id)
  end

  def user_identity
    @user_identity ||= user.identity
  end

  def self.expiry
    Time.now.advance(days: 1)
  end

  def self.generate(user_id)
    self.generate_token(user_id, { expires_at: self.expiry })
  end

end
