class AuthService
  attr_reader :user, :error, :token, :refresh_token

  def initialize(user: nil)
    @user = user
    @error = nil
  end

  def register(user_params)
    @user = User.find_by(email: user_params[:email])

    if @user
      if @user.email_verified
        @error = "Email has already been taken"
        return false
      else
        # Smart Upsert: Update existing unverified user
        @user.assign_attributes(user_params)
      end
    else
      # New User
      @user = User.new(user_params)
      @user.email_verified = false
    end

    if @user.save
      generate_and_send_otp
      true
    else
      @error = @user.errors.full_messages
      false
    end
  end

  def verify_otp(email, otp)
    @user = User.find_by(email: email)

    if @user && @user.otp_code == otp && @user.otp_expires_at > Time.current
      @user.update(email_verified: true, otp_code: nil, otp_expires_at: nil)
      generate_tokens
      true
    else
      @error = "Invalid or expired verification code"
      false
    end
  end

  def resend_otp(email)
    @user = User.find_by(email: email)

    if @user
      generate_and_send_otp
      true
    else
      @error = "User not found"
      false
    end
  end

  def login(email, password)
    @user = User.find_by(email: email)

    if @user&.authenticate(password)
      if @user.email_verified
        generate_tokens
        true
      else
        @error = "Please verify your email address before logging in."
        false
      end
    else
      @error = "Invalid email or password"
      false
    end
  end

  def refresh_token(refresh_token)
    decoded = JsonWebToken.decode(refresh_token)

    if decoded
      @user = User.find_by(id: decoded[:user_id])
      # Only generate new access token, keep refresh token logic if needed or just return simple token
      @token = JsonWebToken.encode({ user_id: @user.id })
      true
    else
      @error = "Invalid refresh token"
      false
    end
  end

  private

  def generate_and_send_otp
    otp = sprintf("%06d", rand(100000..999999))
    @user.update(otp_code: otp, otp_expires_at: 10.minutes.from_now)
    UserMailer.send_otp_email(@user, otp).deliver_now
  end

  def generate_tokens
    @token = JsonWebToken.encode({ user_id: @user.id })
    @refresh_token = JsonWebToken.refresh_token(@user.id)
  end
end
