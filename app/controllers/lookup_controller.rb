class LookupController < ApplicationController
  include RateLimitable

  # Rate limit public lookup: 20 requests per minute per IP
  before_action -> { rate_limit!("public_lookup", limit: 20, period: 1.minute) },
    only: %i[show]

  def index
  end

  def show
    reference = params[:reference].to_s.strip.gsub(/[^a-zA-Z0-9\-_]/, "")
    @case = Case.find_by(reference: reference)
    if @case.nil?
      redirect_to public_lookup_path, alert: "No case found with that reference."
    end
  end
end
