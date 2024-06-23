require 'sidekiq/api'

class ReminderDeletionJob
  include Sidekiq::Worker

  def perform(task_id)
    binding.pry
    # Retrieve the task and delete associated reminder jobs
    task = Task.where(id: task_id).first
    jobs_to_delete = Sidekiq::ScheduledSet.new.select do |job|
      job.args.first == task.id && job.queue == 'default' && job.klass == 'ReminderJob'
    end

    jobs_to_delete.each(&:delete)
  end
end
