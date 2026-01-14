class UserMailer < ApplicationMailer
  default from: 'karanverma2912@gmail.com'

  def send_otp_email(user, otp)
    @user = user
    @otp = otp
    mail(to: @user.email, subject: 'Your Verification Code')
  end
end
