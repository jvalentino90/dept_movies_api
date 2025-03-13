class ApplicationController < ActionController::API
  before_action :set_locale, :authenticate_user

  rescue_from StandardError, with: :error_during_processing

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  def authenticate_user
    if api_key.blank?
      render json: { error: I18n.t('must_specify_api_key') }, status: :unauthorized
    elsif api_key != Rails.application.secrets.api_key
      render json: { error: I18n.t('invalid_api_key') }, status: :unauthorized
    end
  end

  def api_key
    bearer_token || params[:token]
  end

  def bearer_token
    pattern = /^Bearer /
    header = request.headers["Authorization"]
    header.gsub(pattern, '') if header.present? && header.match(pattern)
  end
  def error_during_processing(exception)
    Rails.logger.error(exception.message)
    Rails.logger.error(exception.backtrace.join("\n"))

    render json: { exception: exception.message }, status: :unprocessable_entity
  end
end

