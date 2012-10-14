namespace :reports do

  desc 'Send mailboxes report by email'
  task :send => :environment do
    ReportsSender.send!
  end

end
