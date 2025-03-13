# frozen_string_literal: true
require 'faraday'
require 'json'

class MovieService
  BASE_URL = "#{Rails.application.secrets.movie_service_url}/3"
  API_KEY = Rails.application.secrets.movie_service_api_key
  TRAILER_SITES = ['YouTube', 'Vimeo']

  class ConnectionError < StandardError; end

  class << self
    def fetch_movies(params)
      query = URI.encode_www_form(params)
      response = connection.get("#{BASE_URL}/search/movie?#{query}")
      body = response.body
      unless response.success?
        raise ConnectionError, "Error in request, status: #{response.status}, body: #{body}"
      end

      response.body.deep_symbolize_keys
    end

    def fetch_trailers(movie_id, page)
      response = connection.get("#{BASE_URL}/movie/#{movie_id}/videos?page=#{page}")
      body = response.body
      unless response.success?
        raise ConnectionError, "Error in request, status: #{response.status}, body: #{body}"
      end
      filter_trailers(response.body['results'])
    end


    private
    def connection
      Faraday.new(url: BASE_URL) do |conn|
        conn.headers['Authorization'] = "Bearer #{API_KEY}"
        conn.headers.merge!('Accept': 'application/json', 'Content-Type': 'application/json')
        conn.response(:json, content_type: /\bjson$/)
        conn.adapter(Faraday.default_adapter)
      end
    end

    def filter_trailers(videos)
      videos.map do |video|
        site = video['site']
        next unless video['type'] == 'Trailer' && TRAILER_SITES.include?(site)
        {
          site: site,
          url: obtain_trailer_url(site, video['key']),
          name: video['name'],
          official: video['official']
        }
      end.compact
    end

    def obtain_trailer_url(site, key)
      case site
      when 'YouTube'
        "https://www.youtube.com/watch?v=#{key}"
      when 'Vimeo'
        "https://vimeo.com/#{key}"
      end
    end
  end
end