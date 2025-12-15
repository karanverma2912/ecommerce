
# app/controllers/api/v1/auth_controller.rb
module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request, only: [ :login, :register, :refresh ]

      def register
        @user = User.new(user_params)

        if @user.save
          token = JsonWebToken.encode({ user_id: @user.id })
          render json: {
            user: UserSerializer.new(@user).as_json,
            token: token,
            refresh_token: JsonWebToken.refresh_token(@user.id),
            message: "User registered successfully"
          }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        @user = User.find_by(email: params[:email])

        if @user&.authenticate(params[:password])
          token = JsonWebToken.encode({ user_id: @user.id })
          render json: {
            user: UserSerializer.new(@user).as_json,
            token: token,
            refresh_token: JsonWebToken.refresh_token(@user.id),
            message: "Logged in successfully"
          }, status: :ok
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

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
      end
    end
  end
end
