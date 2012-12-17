if Rails.env.production?
  Delayed::Job.scaler = :heroku_cedar
else
  Delayed::Job.scaler = :local
end

