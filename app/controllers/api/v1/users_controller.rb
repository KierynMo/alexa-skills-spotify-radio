class Api::V1::UsersController < ApplicationController

  def create
    if params[:error]
      puts "LOGIN ERROR", params
      redirect_to "http://localhost:3000/login/failure"
    else
      body = {
            grant_type: "authorization_code",
            code: params[:code],
            redirect_uri: ENV['REDIRECT_URI'],
            client_id: ENV['CLIENT_ID'],
            client_secret: ENV["CLIENT_SECRET"]
          }
      auth_response = RestClient.post('https://accounts.spotify.com/api/token', body)
      auth_params = JSON.parse(auth_response.body)
      header = {
        Authorization: "Bearer #{auth_params["access_token"]}"
      }
      user_response = RestClient.get('https://api.spotify.com/v1/me/player/currently-playing?market=GB', header)
      user_params = JSON.parse(user_response.body)
      current_track_id = user_params["item"]["id"]
      recommendations_response = RestClient.get("https://api.spotify.com/v1/recommendations?limit=10&market=GB&seed_tracks=#{current_track_id}", header)
      raise
    end
  end
end
