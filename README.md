# Taskey

Taskey is a task management application that integrates seamlessly with Google Calendar to help you manage your tasks efficiently. The app allows users to create, update, and delete tasks, which are then synced with their Google Calendar. Additionally, Taskey sends email reminders to users about their pending tasks.

## Features

- User authentication with Devise
- Google OAuth2 integration for Google Calendar API
- Create, update, and delete tasks
- Sync tasks with Google Calendar
- Email reminders for tasks, sent 1 day and 1 hour before the task deadline
- Use of MongoDB with Mongoid ODM
- Background job processing with Sidekiq for sending reminders

## Getting Started

These instructions will help you set up and run the project on your local machine for development and testing purposes.

### Prerequisites

- Ruby 2.7.7
- Rails 6.x
- MongoDB v6.0.15
- Redis v6.2(for Sidekiq)
- Bundler
- Mailcatcher (for local email testing)
- Google Cloud project with OAuth2 credentials

### Installation

1. **Clone the repository:**
    ```sh
    git clone https://github.com/yourusername/taskey.git
    cd taskey
    ```

2. **Install dependencies:**
    ```sh
    bundle install
    ```

3. **Set up the database:**
    Ensure MongoDB is running on your system. Configure MongoDB settings in `config/mongoid.yml`.

4. **Set up environment variables:**

    Create a `.env` file in the root directory and add your environment variables:
    ```
    GOOGLE_CLIENT_ID=314639970544-fr1l796fv1kcqevkspmpespacj3uqred.apps.googleusercontent.com
    GOOGLE_CLIENT_SECRET=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
    GOOGLE_REDIRECT_URI=http://localhost:8888/users/auth/google_oauth2/callback
    ```

5. **Set up Devise:**
    Generate Devise views and run the installer if you haven't already:
    ```sh
    rails generate devise:install
    rails generate devise User
    rails db:migrate
    ```

6. **Set up Sidekiq:**
    Configure Sidekiq by adding the following to `config/application.rb`:
    ```ruby
    config.active_job.queue_adapter = :sidekiq
    ```
    And create a Sidekiq initializer `config/initializers/sidekiq.rb`:
    ```ruby
    Sidekiq.configure_server do |config|
      config.redis = { url: 'redis://localhost:6379/0' }
    end

    Sidekiq.configure_client do |config|
      config.redis = { url: 'redis://localhost:6379/0' }
    end
    ```

7. **Set up Mailcatcher:**
    Install and start Mailcatcher:
    ```sh
    gem install mailcatcher
    mailcatcher
    ```
    Configure Action Mailer to use Mailcatcher in `config/environments/development.rb`:
    ```ruby
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = { address: '127.0.0.1', port: 1025 }
    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    ```

8. **Start the application:**
    ```sh
    rails s -p 8888
    ```

9. **Start Sidekiq:**
    ```sh
    bundle exec sidekiq
    ```

10. **Access the application:**
    Open your browser and navigate to `http://localhost:8888`.

## Usage

1. **Sign Up / Sign In:**
    - Users can sign up or sign in using the Devise authentication system.
    - For now I have only kept Sign in with Google which uses OmniAuth2 for account authorization implemented in the App.
    - Please use the dummy test account that I have created for testing purposes of the application -
   ```
    email_id: dummyusertest23@gmail.com
    password: password@234
    ```

2. **Google Calendar Integration:**
    - After signing in, connect your Google account to sync tasks with Google Calendar.
    - While signing in you need to give permissions to for all the services that it will ask for as that will determine your access_token scope. If the all the permissions are not granted some functionality may not work for you.

3. **CRUD Tasks:**
    - Create, Read, Update, Delete tasks through the UI which is majorly developed on top of Bootstrap 4.
    - These tasks will be created as events in your Google Calendar.
    - These tasks updates are auto synced with Google Calendar synchronously meaning you will not have to create your events in Google Calendar seperately.

4. **Email Reminders:**
    - The Task owners will recieve email notification 1 day and 1 hour prior to the deadline of the task and reminder to complete it.
    - This is implemented through async functionality using Sidekiq Jobs.
    - If the task finished before the deadline and marked as 'done', the queued jobs will be deleted and reminders will not be sent for these tasks.

## Contributing

I Hope you find this application useful!
We welcome contributions to Taskey! Please follow these steps to contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Create a new Pull Request.

## Acknowledgments

- [Devise](https://github.com/heartcombo/devise)
- [Mongoid](https://github.com/mongodb/mongoid)
- [Sidekiq](https://github.com/mperham/sidekiq)
- [Mailcatcher](https://mailcatcher.me/)
- [Google Calendar API](https://developers.google.com/calendar)

