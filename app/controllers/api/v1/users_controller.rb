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
      @header = {
        Authorization: "Bearer #{auth_params["access_token"]}"
      }

      user_response = RestClient.get('https://api.spotify.com/v1/me/player/currently-playing?market=GB', @header)
      user_params = JSON.parse(user_response.body)
      current_track_id = user_params["item"]["id"]

      recommendations_response = RestClient.get("https://api.spotify.com/v1/recommendations?limit=10&market=GB&seed_tracks=#{current_track_id}", @header)
      recommended_tracks = JSON.parse(recommendations_response.body)
      @recommended_track_ids = recommended_tracks["tracks"].map{ |track| track['id'] }
      playlist
    end
  end

  def playlist
    #1. get all users playlists
    user_playlists_response = RestClient.get("https://api.spotify.com/v1/me/playlists?limit=50", @header)
    user_playlists_params = JSON.parse(user_playlists_response.body)
    user_playlists = user_playlists_params["items"].map{ |playlist| {playlist['name'] => playlist['id']} }
    raise
    #2. check if playlist is present
    #3.    if present - get all the tracks
    #4.    delete all the tracks in the playlist
    #5. if playlist is not present create playlist
    #6. populate playlist with recommended songs

  end
end
