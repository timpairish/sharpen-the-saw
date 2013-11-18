require 'rspec'
require 'set'
 
class TicTacToe
  attr_reader :current_player
 
  def initialize
    @current_player = 'O'
    @plays = {
      'O' => [],
      'X' => [],
    }
  end
 
  def at(x, y)
    @plays.keys.each do |player|
      return player if @plays[player].include?([x, y])
    end
    nil
  end
 
  def play(x, y)
    raise OutOfBoundsException if x.abs > 1 || y.abs > 1
    return if at(x, y)
    @plays[@current_player] << [x,y]
    # toggle current player
    @current_player = @current_player == 'O' ? 'X' : 'O'
  end
 
  def winner
    @plays.keys.each do |player|
      (-1..1).each do |index|
        return player if @plays[player].select {|tuple| tuple.first == index}.count == 3
        return player if @plays[player].select {|tuple| tuple.last == index}.count == 3
        return player if @plays[player].select {|tuple| tuple.last == tuple.first}.count == 3
        return player if @plays[player].select {|tuple| tuple.last == (-1 * tuple.first)}.count == 3
      end
    end
    nil
  end
end
 
class OutOfBoundsException < Exception; end
 
 
describe 'TicTacToe' do
  subject(:game) { TicTacToe.new }
 
  it "lets the players take turns placing markers" do
    expect(game.at(0, 0)).to be_nil
    game.play(0, 0)
    expect(game.at(0, 0)).to eql 'O'
    game.play(1, 1)
    expect(game.at(1, 1)).to eql 'X'
  end
  it "won't let a player play outside the board (3x3)?" do
    expect { game.play(-2, 0) }.to raise_error(OutOfBoundsException)
    expect { game.play(0, 2) }.to raise_error(OutOfBoundsException)
    expect { game.play(-2, -5) }.to raise_error(OutOfBoundsException)
  end
  it "does not let a player place a marker in a taken space" do
    game.play(0, 0)
    expect(game.at(0, 0)).to eql 'O'
    game.play(0, 0)
    expect(game.at(0, 0)).to eql 'O'
  end
  it "does not advance the current player after an invalid play" do
    game.play(0, 0)
    expect(game.current_player).to eql 'X'
    game.play(0, 0)
    expect(game.current_player).to eql 'X'
  end
 
  context "winning" do
    it "is won when one player has 3 in a row vertically" do
      expect(game.winner).to be_nil
      game.play(0, 0) # O
      game.play(-1, -1) # X
      game.play(0, -1) # O
      game.play(1, 1) # X
      game.play(0, 1) # O
      expect(game.winner).to eql 'O'
    end
    it "is won when one player has 3 in a row horizontally" do
      expect(game.winner).to be_nil
      game.play(0, 0) # O
      game.play(-1, -1) # X
      game.play(-1, 0) # O
      game.play(1, 1) # X
      game.play(1, 0) # O
      expect(game.winner).to eql 'O'
    end
    it "is won when one player has 3 in a row diagonally from right to left" do
      expect(game.winner).to be_nil
      game.play(0, 0) # O
      game.play(-1, 0) # X
      game.play(-1, -1) # O
      game.play(0, 1) # X
      game.play(1, 1) # O
      expect(game.winner).to eql 'O'
    end
    it "is won when one player has 3 in a row diagonally from left to right" do
      expect(game.winner).to be_nil
      game.play(0, 0) # O
      game.play(-1, 0) # X
      game.play(-1, 1) # O
      game.play(0, 1) # X
      game.play(1, -1) # O
      expect(game.winner).to eql 'O'
    end
  end
end
