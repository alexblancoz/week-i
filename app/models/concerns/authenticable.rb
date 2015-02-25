module Authenticable

  extend ActiveSupport::Concern

  included do

    scope :filter_by_email, ->(mail) { where(mail: mail) }

    attr_accessor :password

    validates :password, :password_confirmation, presence: true, if: :password_required?
    validates :password, confirmation: true, length: { minimum: 6 }, if: :password_required?

    before_save :encrypt_new_password

  end

  module ClassMethods

    def authenticate(enrollment, password)
      user = find_by_enrollment(enrollment)
      return user if user && user.authenticated?(password)
    end

    def authenticate_facebook(user_id, token, expiration_date)
      user = find_by_user_id(user_id)
      if user
        begin
          facebook_user = FbGraph2::User.new(user.user_id).authenticate(token)
          if user.auth_token != token
            user.auth_token = token
            user.save
          end
        rescue FbGraph2::Exception
          user = nil
        end
      else
        user = self.new({ user_id: user_id, auth_token: token, expiration_date: expiration_date })
        facebook_user = FbGraph2::User.new(user_id).authenticate(token)
        user.update_from_facebook(facebook_user.fetch)
        user.save
      end
      unless user.nil?
        user = user.errors.empty? ? user : nil
      end
      user
    end

  end

  def authenticated?(password)
    self.hashed_password == encrypt(password)
  end

  protected

  def encrypt_new_password
    return if password.blank?
    self.hashed_password = encrypt(password)
  end

  def password_required?
    hashed_password.blank? || password.present?
  end

  def encrypt(string)
    Encrypt.sha1(string)
  end

end