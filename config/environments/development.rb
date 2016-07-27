Rails.application.configure do

  # Show full error reports.
  config.consider_all_requests_local = true

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.log_level = :debug
end
