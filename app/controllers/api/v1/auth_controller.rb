
# app/controllers/api/v1/auth_controller.rb
module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request, only: [ :login, :register, :refresh, :verify, :resend_otp ]
      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped

      def register
        service = AuthService.new
        if service.register(user_params)
          render json: {
            message: "Registration successful. Please check your email for the verification code.",
            email: service.user.email
          }, status: :created
        else
          render json: { errors: service.error }, status: :unprocessable_entity
        end
      end

      def verify
        service = AuthService.new
        if service.verify_otp(params[:email], params[:otp])
          render json: {
            user: UserSerializer.new(service.user).as_json,
            token: service.token,
            refresh_token: service.refresh_token,
            message: "Email verified successfully"
          }, status: :ok
        else
          render json: { error: service.error }, status: :unauthorized
        end
      end

      def resend_otp
        service = AuthService.new
        if service.resend_otp(params[:email])
          render json: { message: "Verification code resent" }, status: :ok
        else
          render json: { error: service.error }, status: :not_found
        end
      end

      def login
        service = AuthService.new
        if service.login(params[:email], params[:password])
          render json: {
            user: UserSerializer.new(service.user).as_json,
            token: service.token,
            refresh_token: service.refresh_token,
            message: "Logged in successfully"
          }, status: :ok
        else
          status = service.error.include?("verify") ? :forbidden : :unauthorized
          render json: { error: service.error }, status: status
        end
      end

      def refresh
        service = AuthService.new
        if service.refresh_token(params[:refresh_token])
          render json: { token: service.token }, status: :ok
        else
          render json: { error: service.error }, status: :unauthorized
        end
      end

      def logout
        render json: { message: "Logged out successfully" }, status: :ok
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
      end
    end
  end
end
