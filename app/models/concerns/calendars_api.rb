require 'google/apis/calendar_v3'
require 'googleauth'

module CalendarsApi
  include ActiveSupport::Concern

  def get_google_calendar_client(current_user)
    client = Google::Apis::CalendarV3::CalendarService.new
    return unless (current_user.present? && current_user.access_token.present? && current_user.refresh_token.present?)

    client.authorization = Signet::OAuth2::Client.new(
      client_id: "314639970544-fr1l796fv1kcqevkspmpespacj3uqred.apps.googleusercontent.com",
      client_secret: "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",
      token_credential_uri: 'https://oauth2.googleapis.com/token',
      access_token: current_user.access_token,
      refresh_token: current_user.refresh_token,
      expires_at: current_user.expires_at
    )
    client.authorization.grant_type = "refresh_token"

    if client.authorization.expired?
      client.authorization.refresh!
      current_user.update(
        access_token: client.authorization.access_token,
        refresh_token: client.authorization.refresh_token,
        expires_at: client.authorization.expires_at
      )
    end
    client
  end

  def create_google_task(task)
    client = get_google_calendar_client(task.user)
    g_task = get_task(task)
    ge = client.insert_event(Task::CALENDAR_ID, g_task)
    task.update(google_task_id: ge.id)
  end
  
  def edit_google_task(task)
    client = get_google_calendar_client(task.user)
    g_task = client.get_event(Task::CALENDAR_ID, task.google_task_id)
    ge = get_task(task)
    client.update_event(Task::CALENDAR_ID, task.google_task_id, ge)
  end
  
  def delete_google_task(task)
    client = get_google_calendar_client(task.user)
    client.delete_event(Task::CALENDAR_ID, task.google_task_id)
  end
  
  def get_google_task(task_id, user)
    client = get_google_calendar_client user
    g_task = client.get_event(Task::CALENDAR_ID, task_id)
  end
  
  private

    def get_task(task)
      task = Google::Apis::CalendarV3::Event.new({
        summary: task.title,
        description: task.description,
        start: {
          date_time: Time.at(task.created_at).to_datetime.rfc3339,
          time_zone: 'Asia/Tokyo'
        },
        end: {
          date_time: Time.at(task.deadline).to_datetime.rfc3339,
          time_zone: 'Asia/Tokyo'
        }
      })
    end

end