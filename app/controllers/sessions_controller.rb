class SessionsController < ApplicationController

  layout false

  def new
  end

  def create
    if user = User.authenticate(params[:email], params[:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash.now[:alert] = 'Credenciales incorrectas.'
      render action: 'new', notice: 'Credenciales incorrectas'
    end
  end

  def destroy
    reset_session
    redirect_to root_path, :notice => "Sesion cerrada."
  end

end