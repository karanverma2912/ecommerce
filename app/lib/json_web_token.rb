# app/lib/json_web_token.rb
module JsonWebToken
  SECRET = Rails.application.secrets.secret_key_base

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET, "HS256")
  end

  def self.decode(token)
    begin
      decoded = JWT.decode(token, SECRET, true, algorithm: "HS256")
      HashWithIndifferentAccess.new(decoded[0])
    rescue JWT::ExpiredSignature, JWT::DecodeError
      nil
    end
  end

  def self.refresh_token(user_id)
    payload = { user_id: user_id }
    encode(payload, 7.days.from_now)
  end
end
