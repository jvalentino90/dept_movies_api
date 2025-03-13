module Dept
  module V1
    class MoviesController < ApplicationController
      rescue_from MovieService::ConnectionError, with: :connection_error

      def index
        binding.pry
        movies = MovieService.fetch_movies(params.permit(:query, :language, :page, :locale).to_h)
        render json: movies
      end

      def trailers
        movie_id = params[:id]
        trailers = MovieService.fetch_trailers(movie_id, params[:page])
        render json: trailers
      end

      private
      def connection_error(error)
        render json: { error: error.message }, status: :bad_gateway
      end
    end
  end
end