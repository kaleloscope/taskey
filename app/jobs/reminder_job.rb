require 'sidekiq/api'

class ReminderJob
  include Sidekiq::Worker
  queue_as :default

  def perform(user_id, task_id)
    binding.pry
    task = Task.where(id: task_id).first
    user = User.where(id: user_id).first

    if task.status != 'done'
      ReminderMailer.reminder_email(user, task).deliver_now
    else
      Rails.logger.info("Skipping reminder for task #{task.id.to_s} with status Done")
    end
  rescue Google::Apis::ClientError => e
    Rails.logger.error("Failed to retrieve task: #{e.message}")
  end
end
