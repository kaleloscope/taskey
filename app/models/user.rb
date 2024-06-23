class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, 
         :omniauthable, omniauth_providers: [:google_oauth2]
  
  # has_many :tasks, dependent: :destroy
  has_many :tasks

  field :name, type: String
  field :email, type: String
  field :provider, type: String
  field :uid, type: String
  field :provider, type: String
  field :uid, type: String
  field :encrypted_password, type: String
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time
  field :remember_created_at, type: Time

  # Fields related to the authentication
  field :access_token, type: String
  field :refresh_token, type: String
  field :expires_at, type: DateTime

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    unless user
        user = User.create(
           email: data['email'],
           password: Devise.friendly_token[0,20],
           provider: access_token.provider,
           uid: access_token.uid,
           name: data.name,
           access_token: access_token.credentials.token,
           refresh_token: access_token.credentials.refresh_token,
           expires_at: access_token.credentials.expires_at
        )
    end
    user
  end

  def expired?
    expires_at < Time.now.to_i
  end 


end
