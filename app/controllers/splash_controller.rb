class SplashController < ApplicationController

  layout false

  def splash
    render layout: 'layouts/application'
  end

  def index
  end

  def modal
  end
  
  def verify
    crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_key_base)
    enrollment = crypt.decrypt_and_verify(params[:token])
    @user = User.base.filter_by_enrollment(enrollment).first
    @user.update({ verified: true})
    redirect_to action: :splash
  end

end
