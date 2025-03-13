require 'rails_helper'

RSpec.describe MovieService, type: :service do
  describe '.fetch_movies', :vcr do
    let(:params) { { query: 'Inception', page: 1 } }

    context 'when the request is successful' do
      it 'returns the movie data' do
        response = MovieService.fetch_movies(params)
        expect(response).to be_a(Hash)
        expect(response['results']).to be_an(Array)
        expect(response['results'].first).to have_key('title')
        expect(response['page']).to eql(1)
      end
    end

    context 'when the request fails' do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(
          instance_double(Faraday::Response, success?: false, status: 500, body: 'Internal Server Error')
        )
      end

      it 'raises a ConnectionError' do
        expect { MovieService.fetch_movies(params) }.to raise_error(MovieService::ConnectionError, /Error in request/)
      end
    end
  end

  describe '.fetch_trailers', :vcr do
    let(:movie_id) { 123 }
    let(:params) { { language: 'en' } }

    context 'when the request is successful' do
      it 'returns the trailer data' do
        response = MovieService.fetch_trailers(movie_id, params )
        expect(response).to be_an(Array)
        first_element = response.first
        expect(first_element).to have_key(:site)
        expect(first_element).to have_key(:url)
        expect(first_element).to have_key(:name)
        expect(first_element).to have_key(:official)
      end
    end
  end
end