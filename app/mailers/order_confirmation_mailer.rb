class OrderConfirmationMailer < ApplicationMailer
  def payment_confirmed
    @order = params[:order]
    @user = @order.user
    mail(to: @user.email, subject: "Order Confirmation ##{@order.id}")
  end
end
