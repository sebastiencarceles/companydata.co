class CommandsController < ActionController::API
  def create
    return render json: {}, status: 403 unless valid_slack_token?
    pp params    
    render json: { response_type: "ephemeral" }, status: :created
  end

  private

    def valid_slack_token?
      params[:token] == Figaro.env.SLACK_SLASH_COMMAND_TOKEN
    end

    def command_params
      params.permit(:text, :token, :user_id, :response_url)
    end
end