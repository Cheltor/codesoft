#class ServiceWorkerController < ActionController::Base
#    protect_from_forgery except: :index
#  
#    def index
#      # Serve the service worker file from the assets pipeline
#      respond_to do |format|
#        format.js { render file: Rails.root.join('app', 'assets', 'javascripts', 'service-worker.js'), content_type: 'application/javascript' }
#      end
#    end
#  end
  