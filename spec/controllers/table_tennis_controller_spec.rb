require 'rails_helper'

RSpec.describe 'Table Tennis API', type: :request do
  describe '#ping' do
    context 'when unauthenticated' do
      it 'returns unauthenticated pong' do
        get '/ping'
        expect(parsed_body['response']).to eq 'unauthenticated pong'
      end
    end

    context 'when authenticated' do
      before { get '/ping', headers: authentication_header }

      it 'works' do
        expect(response).to be_success
      end

      it 'returns authenticated pong' do
        expect(parsed_body['response']).to eq 'authenticated pong'
      end
    end
  end
end
