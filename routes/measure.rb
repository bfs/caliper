class App < Sinatra::Base
  $cp =  CaliperBrowser.new
  
  get '/measure' do
    url = params[:url]
    $cp.get_page(url)
    
    content_type :json
    $cp.get_measurements
  end
  
  
  put '/measure' do
    html=request.body.read
    $cp.load_string(html)
    
    
    content_type :json
    $cp.get_measurements
  end
end