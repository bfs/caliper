class App < Sinatra::Base
  $cp =  CaliperBrowser.new
  get '/measure' do
    content_type 'application/json'
    url = params[:url]
    $cp.get_measurements(url)
  end
end