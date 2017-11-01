class TableTennisController < ApiController
  def ping
    if current_user
      render json: { response: 'authenticated pong' }
    else
      render json: { response: 'unauthenticated pong'}
    end
  end
end
