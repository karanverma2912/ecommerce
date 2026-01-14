module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_queue_adapter, only: [:update]

      def show
        @user = current_user
        authorize @user
        render json: @user, serializer: UserSerializer, status: :ok
      end

      def update
        @user = current_user
        authorize @user

        # Ensure adapter is async for this request
        ActiveJob::Base.queue_adapter = :async

        if @user.update(user_params)
          render json: @user, serializer: UserSerializer, status: :ok
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_queue_adapter
        ActiveJob::Base.queue_adapter = :async
      end

      def user_params
        params.permit(:first_name, :last_name, :phone, :address, :city, :state, :zip_code, :country, :avatar)
      end
    end
  end
end
