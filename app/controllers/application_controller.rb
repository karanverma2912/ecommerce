class ApplicationController < ActionController::Base
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection
  
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  include Pundit::Authorization
  include Pagy::Method

  before_action :authenticate_request
  after_action :verify_authorized, unless: :skip_pundit? # Adjusted to simplify
  after_action :verify_policy_scoped, if: -> { action_name == "index" && !skip_pundit? }

  attr_reader :current_user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from Stripe::CardError, with: :handle_stripe_error

  private

  def authenticate_request
    return if skip_authentication?

    token = request.headers["Authorization"]&.split(" ")&.last
    decoded = JsonWebToken.decode(token) if token

    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
      render json: { error: "Invalid token" }, status: :unauthorized unless @current_user
    else
      # If not JSON request (e.g. ActiveAdmin), do not enforce token auth but skip @current_user
      if request.format.json?
         render json: { error: "Missing or invalid token" }, status: :unauthorized
      end
    end
  end

  def skip_authentication?
    # Skip for authentication logic
    action_name == "login" || action_name == "register" || action_name == "refresh"
  end

  def skip_pundit?
    action_name == "index"
  end



  def user_not_authorized
    if request.format.json?
      render json: { error: "User not authorized" }, status: :forbidden
    else
      flash[:alert] = "You are not authorized to perform this action."
      redirect_back(fallback_location: root_path)
    end
  end

  def record_not_found(exception)
    if request.format.json?
      render json: { error: exception.message }, status: :not_found
    else
      render file: "public/404.html", status: :not_found, layout: false
    end
  end

  def handle_stripe_error(exception)
    render json: { error: exception.message }, status: :payment_required
  end
end

