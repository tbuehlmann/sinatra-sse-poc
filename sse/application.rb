require 'sinatra/base'

require 'sse/broadcast_list'
require 'sse/event'
require 'sse/stream'

module SSE
  class Application < Sinatra::Base
    set :broadcast_list, BroadcastList.new
    
    get '/' do
      erb :index
    end
    
    get '/sse' do
      stream = Stream.new
      settings.broadcast_list.add(stream)
      headers['Content-Type'] = 'text/event-stream'
      body = Rack::BodyProxy.new(stream) { settings.broadcast_list.remove(stream) }

      [200, body]
    end
    
    post '/messages' do
      escaped_message = Rack::Utils.escape_html(params[:message])
      event = SSE::Event.new(event: 'chat', data: escaped_message)
      settings.broadcast_list.broadcast(event)

      200
    end
  end
end
