class Api::V1::LoginController < ApplicationController

  def spotify_request
    url = "https://accounts.spotify.com/authorize"
    query_params = {
      client_id: ENV['CLIENT_ID'],
      response_type: 'code',
      redirect_uri: 'http://localhost:3000/api/v1/user',
      scope: "user-read-private
      user-read-recently-played
      user-read-currently-playing
      user-modify-playback-state
      playlist-modify-public
      playlist-modify-private
      playlist-read-private
      playlist-read-collaborative",
      show_dialog: true
    }
    redirect_to "#{url}?#{query_params.to_query}"
  end

  def alexa
    print "HELLOOOOOOO"
    json_params = JSON.parse(request.raw_post)
    print json_params
    binding.pry
  end
end
