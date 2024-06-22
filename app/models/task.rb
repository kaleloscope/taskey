class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title, type: String
  field :description, type: String
  field :status, type: String
  field :deadline, type: DateTime

  belongs_to :user

  validates :title, :description, :deadline, :status, presence: true
  validates :status, inclusion: { in: %w[backlog in_progress done] }

  def validate_event_dates
    return if deadline.nil?
    
    if created_at > deadline
      errors.add(:deadline, 'must be greater than created date')
    end
  end

end

