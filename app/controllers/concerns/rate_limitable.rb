module RateLimitable
  extend ActiveSupport::Concern

  class RateLimitExceeded < StandardError; end

  included do
    rescue_from RateLimitExceeded, with: :rate_limit_exceeded_response
  end

  private

  # Simple in-memory rate limiter using Rails.cache.
  # Limits requests per IP per action within a time window.
  #
  # Usage in controller:
  #   before_action -> { rate_limit!("llm_generate", limit: 10, period: 1.minute) }, only: [:create]
  #
  def rate_limit!(key, limit: 10, period: 1.minute)
    cache_key = "rate_limit:#{key}:#{request.remote_ip}"
    count = Rails.cache.read(cache_key).to_i

    if count >= limit
      raise RateLimitExceeded, "Rate limit exceeded. Try again later."
    end

    Rails.cache.write(cache_key, count + 1, expires_in: period)
  end

  def rate_limit_exceeded_response(exception)
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :too_many_requests }
    end
  end
end
