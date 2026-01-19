
# app/controllers/api/v1/auth_controller.rb
module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request, only: [ :login, :register, :refresh, :verify, :resend_otp ]
      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped

      def register
        @user = User.find_by(email: user_params[:email])

        if @user
          if @user.email_verified
            return render json: { errors: [ "Email has already been taken" ] }, status: :unprocessable_entity
          else
            # Smart Upsert: Update existing unverified user
            @user.assign_attributes(user_params)
            # Proceed to save and resend OTP
          end
        else
          # New User
          @user = User.new(user_params)
          @user.email_verified = false
        end

      if @user.save
        generate_and_send_otp(@user)

        render json: {
          message: "Registration successful. Please check your email for the verification code.",
          email: @user.email
        }, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
      end

      def verify
        email = params[:email]
        otp = params[:otp]

        @user = User.find_by(email: email)

        if @user && @user.otp_code == otp && @user.otp_expires_at > Time.current
          @user.update(email_verified: true, otp_code: nil, otp_expires_at: nil)

          token = JsonWebToken.encode({ user_id: @user.id })
          render json: {
            user: UserSerializer.new(@user).as_json,
            token: token,
            refresh_token: JsonWebToken.refresh_token(@user.id),
            message: "Email verified successfully"
          }, status: :ok
        else
          render json: { error: "Invalid or expired verification code" }, status: :unauthorized
        end
      end

      def resend_otp
        email = params[:email]
        @user = User.find_by(email: email)

        if @user
          generate_and_send_otp(@user)

          render json: { message: "Verification code resent" }, status: :ok
        else
          render json: { error: "User not found" }, status: :not_found
        end
      end

      def login
        @user = User.find_by(email: params[:email])

        if @user&.authenticate(params[:password])
          if @user.email_verified
            token = JsonWebToken.encode({ user_id: @user.id })
            render json: {
              user: UserSerializer.new(@user).as_json,
              token: token,
              refresh_token: JsonWebToken.refresh_token(@user.id),
              message: "Logged in successfully"
            }, status: :ok
          else
            render json: {
              error: "Please verify your email address before logging in.",
              email_verified: false
            }, status: :forbidden
          end
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def refresh
        decoded = JsonWebToken.decode(params[:refresh_token])

        if decoded
          @user = User.find_by(id: decoded[:user_id])
          token = JsonWebToken.encode({ user_id: @user.id })
          render json: { token: token }, status: :ok
        else
          render json: { error: "Invalid refresh token" }, status: :unauthorized
        end
      end

      def logout
        render json: { message: "Logged out successfully" }, status: :ok
      end

      private

      def generate_and_send_otp(user)
        otp = sprintf("%06d", rand(100000..999999))
        user.update(otp_code: otp, otp_expires_at: 10.minutes.from_now)
        UserMailer.send_otp_email(user, otp).deliver_now
      end

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
      end
    end
  end
end
