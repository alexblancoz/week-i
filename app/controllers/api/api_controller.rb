class Api::ApiController < ApplicationController

  module LIMIT
    PER_PAGE = 25
  end

  attr_accessor :app_session
  respond_to :json

  protected

  def assert_user
    render_error(:unauthorized, "Bad credentials") if self.app_session.nil?
    @user = Api::User.find_by_id(self.app_session.id)
  end

  def assert_teacher
    assert_user
    ban_user if @user.identity != Api::User::Identity::TEACHER
  end

  def assert_administrator
    assert_user
    ban_user if @user.identity != Api::User::Identity::ADMINISTRATOR
  end

  def ban_user
    render_error(:unauthorized, 'Tu cuenta ha sido baneada, contacta a un administrador.')
    @user.active = false
    @user.save
  end

  def app_session
    @app_session ||= ->{
      data = self.request.headers
      if data['Auth-Token'].present? && data['Auth-Secret'].present?
        token = Api::Token.filter_by_token(data['Auth-Token'], data['Auth-Secret']).first
        unless token.nil?
          token.renew
          token.save
          token.user
        end
      end
    }.call
  end

  def render_error(status, message)
    render json: { error: { message: message } }, status: status
  end

  def render_errors(status, collection)
    render json: { errors: collection }, status: status
  end

  def paginate(collection)
    if params[:per_page].present?
      headers['Total'] = collection.count(:id).to_s
      return collection.apply_limit(params, [params[:per_page].to_i, LIMIT::PER_PAGE].min)
    end
    collection
  end

end
