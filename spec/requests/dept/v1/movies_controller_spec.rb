require 'rails_helper'

RSpec.describe Dept::V1::MoviesController, type: :request do
  let(:token) { 'ca1fa54e3323e51fdfde4d19ae37b228' }
  describe 'GET /dept/v1/movies' do
    context 'with a valid API Key' do
      let(:params) {{ query: 'The Naked Gun', page: 1, token: token } }

      subject { get "/dept/v1/movies", params: params }
      before do
        allow(MovieService).to receive(:fetch_movies).and_return(movie_service_response)
      end

      let(:movie_service_response) { read_json_fixture('response/movie_service/movies_response') }

      it 'returns a successful response' do
        subject
        body = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(body['results'].count).to eql(10)
        expect(body['total_pages']).to eql(1)
      end

      context 'when MovieService raises a ConnectionError' do
        before do
          allow(MovieService).to receive(:fetch_movies).and_raise(MovieService::ConnectionError, 'Connection failed')
        end

        it 'returns a bad gateway response' do
          subject
          body = JSON.parse(response.body)
          expect(response).to have_http_status(:bad_gateway)
          expect(body['error']).to eql('Connection failed')
        end
      end
    end

    context 'with an invalid API Key' do
      it 'returns invalid api key error' do
        get '/dept/v1/movies'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /dept/v1/trailers' do
    subject { get "/dept/v1/movies/#{192544}/trailers?token=#{token}" }
    context 'with an valid API Key' do
      before do
        allow(MovieService).to receive(:fetch_trailers).and_return(movie_service_response)
      end

      let(:movie_service_response) { read_json_fixture('response/movie_service/trailers_response') }

      it 'returns a successful response' do
        subject
        body = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(body['trailers'].count).to eql(2)
        expect(body['total_pages']).to eql(1)
      end
    end
  end
end
