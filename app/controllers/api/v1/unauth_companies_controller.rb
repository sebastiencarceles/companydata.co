# frozen_string_literal: true

class Api::V1::UnauthCompaniesController < ActionController::API
  after_action :track_api_call

  def autocomplete
    query = params[:q]
    render(json: {}, status: :bad_request) && (return) unless query

    results = Company.search(
      query,
      fields: ["smooth_name"],
      match: :word_start,
      where: { quality: "headquarter" },
      limit: 10,
      load: false,
      misspellings: { below: 5 }
    )
    render json: results, each_serializer: Api::V1::LigthCompanySerializer
  end

  private

    def track_api_call
      Tracking::TrackWorker.perform_async("unauthenticated_user", "Unauthenticated API call")      
    end
end
