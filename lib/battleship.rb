class Battleship

  require 'active_support/core_ext/hash/keys'
  require 'json'
  require 'net/http'
  require 'net/https'

  attr_accessor :base_uri, :format, :api_key, :game_id, :token, :current_player
  attr_accessor :name
  attr_accessor :carrierCell
  attr_accessor :status, :moves

  def initialize(id=nil)

    @base_uri = 'http://battleship.inseng.net/'
    @game_id = id
    @name = "nothing"
  end

  def create_game
    return if game_id
    uri = URI("#{base_uri}games")

    res = Net::HTTP.post_form(uri, {})
    puts res.body
    data = JSON.parse(res.body)
    @game_id = data["id"]
    puts game_id
  end

  def join_game
    uri = URI.parse("#{base_uri}games/#{game_id}/players")
    puts uri
    params = {
              'name' => name,
              'carrierCell' => 'A1',
              'carrierDirection' => 'down',
              'battleshipCell' => 'B1',
              'battleshipDirection' => 'down',
              'destroyerCell' => 'C1',
              'destroyerDirection' => 'down',
              'cruiserCell' => 'D9',
              'cruiserDirection' => 'left',
              'submarineCell' => 'J9',
              'submarineDirection' => 'down'
             }
    resp = Net::HTTP.post_form(uri, params)
    data = JSON.parse(resp.body)
    puts data
    @current_player = data["currentPlayer"]
    @token = current_player["token"]
    puts "Current Player: #{current_player}"
    puts "Token: #{token}"
    raise "Oh! Why did we not get a token?!" unless token
    # print current_player["board"]
    @moves = current_player["moves"]
    print current_player["moves"]
  end

  def move(col = 'A', row = 1)
    move = "#{col}#{row}"
    puts move

    uri = URI.parse("#{base_uri}games/#{game_id}/moves")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(move: move)
    request['X-Token'] = token

    response = http.request(request)
    data = JSON.parse(response.body)

    col.next!
    row += 1 if col =='K'
    col = 'A' if col == 'K'
    row = 1 if 1 == 11
    # row -= 1 if col =='A'
    # col = 'K' if col == 'A'
    # row = 10 if 1 == 1

    move(col, row) unless data['state'] == 'FINISHED'
  end

  def play
    create_game
    join_game
    move
  end
end