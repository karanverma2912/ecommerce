# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include Pundit::Authorization
  include Pagy::Method

  before_action :authenticate_request
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

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
      render json: { error: "Missing or invalid token" }, status: :unauthorized
    end
  end

  def skip_authentication?
    action_name == "login" || action_name == "register" || action_name == "refresh"
  end

  def user_not_authorized
    render json: { error: "User not authorized" }, status: :forbidden
  end

  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def handle_stripe_error(exception)
    render json: { error: exception.message }, status: :payment_required
  end
end
