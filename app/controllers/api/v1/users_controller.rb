class Api::V1::UsersController < ApplicationController

  def create
    if params[:error]
      puts "LOGIN ERROR", params
      redirect_to "http://localhost:3000/login/failure"
    else
      # body = {
      #       grant_type: "authorization_code",
      #       code: params[:code],
      #       redirect_uri: ENV['REDIRECT_URI'],
      #       client_id: ENV['CLIENT_ID'],
      #       client_secret: ENV["CLIENT_SECRET"]
      #     }
      # auth_response = RestClient.post('https://accounts.spotify.com/api/token', body)
      # auth_params = JSON.parse(auth_response.body)
      alexa_params = JSON.parse(request.raw_post)
      access_token = alexa_params['session']["user"]['accessToken']
      @header = {
        Authorization: "Bearer #{access_token}"
      }

      current_song_response = RestClient.get('https://api.spotify.com/v1/me/player/currently-playing?market=GB', @header)
      current_song_params = JSON.parse(current_song_response.body)
      @current_track = {current_song_params["item"]['name'] => current_song_params['item']['id']}

      recommendations_response = RestClient.get("https://api.spotify.com/v1/recommendations?limit=10&market=GB&seed_tracks=#{@current_track.values[0]}", @header)
      recommended_tracks = JSON.parse(recommendations_response.body)
      @recommended_track_ids = recommended_tracks["tracks"].map{ |track| track['id'] }
      @recommended_uris = recommended_tracks["tracks"].map { |track| track["uri"] }
      playlist_id = create_playlist
      render json: response_object
      #To stop the play_song starting a song from the previous playlist. It needs a delay
      sleep(5)
      play_song(playlist_id)
    end
  end

  def create_playlist
    #1. get all users playlists
    user_playlists_response = RestClient.get("https://api.spotify.com/v1/me/playlists", @header)
    user_playlists_params = JSON.parse(user_playlists_response.body)
    user_playlists = user_playlists_params["items"].map{ |playlist| {playlist['name'] => playlist['id']} }

    @current_user_id = user_playlists_params["items"].first['owner']['id']

    # test_playlist_response = RestClient.get("https://api.spotify.com/v1/users/#{@current_user_id}/playlists", @header)
    # test_playlist_params = JSON.parse(test_playlist_response.body)
    #2. check if playlist is present

    playlist_names = user_playlists.map{ |playlist| playlist.keys.first }
    unless playlist_names.include? "Recommended by Alexa"
      body = {
        name: "Recommended by Alexa",
        description: "Alexa Radio",
        public: false
      }

      create_playlist_response = RestClient.post("https://api.spotify.com/v1/users/#{@current_user_id}/playlists", body.to_json, @header)
      create_playlist_params = JSON.parse(create_playlist_response.body)
      alexa_playlist_id = { "Recommended by Alexa" => create_playlist_params["id"] }
    end

    alexa_playlist_id = user_playlists.find { |playlist| playlist.keys.first == "Recommended by Alexa" } unless alexa_playlist_id

    update_URL = "https://api.spotify.com/v1/playlists/#{alexa_playlist_id["Recommended by Alexa"]}/tracks?uris="
    uris = ""
    @recommended_uris.each { |uri| uris << uri << "," }
    uris = uris[0..-2]
    update_URL << ERB::Util.url_encode(uris)
    update_playlist_response = RestClient.put(update_URL, "", @header)
    #return playlist_id to be used as a param in the play_song function
    alexa_playlist_id
  end

#   def response_header
#     {
#     Content-Type : application/json;charset=UTF-8

# Host : your.application.endpoint
# Content-Length :
# Accept : application/json
# Accept-Charset : utf-8
# Signature:
# SignatureCertChainUrl: https://s3.amazonaws.com/echo.api/echo-api-cert.pem
# }
#   end

  def play_song(playlist_id)
    body = {
      context_uri: "spotify:playlist:#{playlist_id.values.first}"
    }

    play_song_response = RestClient.put('https://api.spotify.com/v1/me/player/play', body.to_json, @header)
  end

  def response_object
    {
      version: "1.0",
      response: {
        outputSpeech: {
          type: "PlainText",
          text: "I have created a playlist of similar tracks. Hope you enjoy!",
          playBehavior: "REPLACE_ENQUEUED"
        }
      }
    }
  end
end
