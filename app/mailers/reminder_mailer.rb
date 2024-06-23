class ReminderMailer < ApplicationMailer
  default from: 'taskey_notifications@example.com'

  def reminder_email(user, task)
    @user = user
    @task = task
    mail(to: @user.email, subject: 'Task Reminder')
  end
end
