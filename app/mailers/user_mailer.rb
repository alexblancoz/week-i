class UserMailer < ActionMailer::Base
  default from: 'contacto@bemeer.com'

  def validate_user(user)
    @user = user
    crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_key_base)
    encrypted_data = crypt.encrypt_and_sign(@user.enrollment)
    @url = "http://162.243.135.222/verify?token=#{encrypted_data}"
    mail(to: "#{@user.enrollment}@itesm.mx", subject: 'Bienvenido a Espacios de Innovación, Verifica tu cuenta')
  end
end
