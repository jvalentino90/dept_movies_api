class MoviesController < ApplicationController
  def index
    movies = MovieService.fetch_movies
    render json: movies
  end

  def trailers
    movie_id = params[:id]
    trailers = MovieService.fetch_trailers(movie_id)
    render json: trailers
  end
end