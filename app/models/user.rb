class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, 
         :omniauthable, omniauth_providers: [:google_oauth2]
  
  has_many :tasks, dependent: :destroy

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

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    unless user
        user = User.create(
           email: data['email'],
           password: Devise.friendly_token[0,20],
           provider: access_token.provider,
           uid: access_token.uid
        )
    end
    user
  end


end
