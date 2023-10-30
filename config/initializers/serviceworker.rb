Rails.application.configure do
  config.serviceworker.routes.draw do
    match "/service-worker.js" => "service-worker.js"
  end
end