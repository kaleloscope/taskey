class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include CalendarsApi

  CALENDAR_ID = 'primary'
  
  field :title, type: String
  field :description, type: String
  field :status, type: String
  field :deadline, type: DateTime

  belongs_to :user

  validates :title, :description, :deadline, :status, presence: true
  validates :status, inclusion: { in: %w[backlog in_progress done] }
  validate :validate_deadline

  after_create :create_task_in_calendar
  after_update :update_task_in_calendar
  before_destroy :remove_task_from_calendar


  def create_task_in_calendar
    self.create_google_task(self)
    schedule_reminders if self.status != 'done'
  end

  def update_task_in_calendar
    self.edit_google_task(self)
    delete_reminder_jobs if self.status == 'done'
  end

  def remove_task_from_calendar
    self.delete_google_task(self)
    delete_reminder_jobs
  end

  private

    def validate_deadline
      return if deadline.nil?
      
      if Time.now > self.deadline
        errors.add(:deadline, 'must be greater than created date')
      end
    end

    def schedule_reminders
      task_user_id = self.user.id.to_s
      if self.deadline > Time.now + 1.days
        one_day_before = self.deadline - 1.day
        ReminderJob.perform_at(one_day_before, task_user_id, self.id.to_s)
      end
      if self.deadline > Time.now + 1.hour
        # one_hour_before = self.deadline - 1.hour
        one_hour_before = Time.now + 1.minute
        ReminderJob.perform_at(one_hour_before, task_user_id, self.id.to_s)
      end
    end

    def delete_reminder_jobs
      ReminderDeletionJob.perform_async(self.id.to_s)
    end

end

