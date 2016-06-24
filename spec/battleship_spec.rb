require_relative 'spec_helper'

describe Battleship do

  it 'should play with itself' do
    # Not async, hangs on join game
    bs1 = Battleship.new
    bs1.create_game
    id = bs1.game_id
    bs2 = Battleship.new(id)
    puts 'hereee'
    fork(bs2.join_game)
    puts 'there'
    fork(bs1.move)
    puts 'everywhere'
    bs2.play
  end
end