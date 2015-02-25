module Tokenable

  extend ActiveSupport::Concern

  included do

    scope :filter_by_token, ->(token, secret){ where(token: token, secret: secret) }
    scope :filter_by_user, ->(user_id){ where(user_id: user_id) }
    scope :valid, -> { where("#{self.expires_at_field} > ?", Time.now)  }

    #attr_protected :token, :secret
    validates :user_id, presence: true, numericality: { only_integer: true }
    before_create :generate_token

    def serialize
      @serialize ||= { token: self.token, secret: self.secret }
    end

    def renew
      self.expires_at = self.class.expiry
      self.save
    end

    protected

    def generate_token
      json_token = self.token_obj.to_json
      self.token = Base64.urlsafe_encode64(json_token)
      salt = Encrypt.sha1(json_token)
      self.secret = Base64.urlsafe_encode64(salt)
    end

    def token_obj
      @token_obj ||= -> {
        now = Time.now
        { user_id: self.user_id, salt: Encrypt.sha1(self.user_id, now) }
      }.call
    end

    def self.expires_at_field
      @expires_at_field ||= "#{self.table_name}.expires_at"
    end

  end

  module ClassMethods

    def generate_token(user_id, args = {})
      el = self.new
      el.user_id = user_id
      args.each_pair do |key, val|
        el.send("#{key}=", val)
      end
      el
    end

    def expiry
      raise NotImplementedError if self.expires?
    end

    def find_by_user(user_id, conditions={})
      el = self.base.filter_by_user(user_id)
      el = el.where(conditions) unless conditions.empty?
      el = el.valid if self.expires?
      el.first
    end

    def find_token(token, secret, conditions={})
      el = nil
      begin
        token_data = Base64.urlsafe_decode64(token)
        secret_data = Base64.urlsafe_decode64(secret)
        salt = ApplicationController.encrypt(token_data)
        if secret_data == salt
          data = JSON.parse(token_data)
          el = self.base.filter_by_token(token, secret).filter_by_user(data['user_id']).order(nil)
          el = el.where(conditions) unless conditions.empty?
          el = el.valid if self.expires?
          el = el.first
        end
      rescue
        #Empty
      end
      el
    end

    def expires?
      self.attribute_method?(:expires_at)
    end

  end

end
