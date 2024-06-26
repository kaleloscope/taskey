require 'sidekiq/api'

class ReminderDeletionJob
  include Sidekiq::Worker

  # Retrieve the task and delete associated reminder jobs
  def perform(task_id)
    jobs_to_delete = Sidekiq::ScheduledSet.new.select do |job|
      job.args.second == task_id && job.queue == 'default' && job.klass == 'ReminderJob'
    end

    jobs_to_delete.each(&:delete)
  end
end
