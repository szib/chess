require './lib/Game.rb'

RSpec.describe Game do
  let(:game) do
    Game.new
  end

  it 'has a play method' do
    expect(game).to respond_to(:play)
  end

  context 'save/load game' do
    it 'save/load current_player' do
      game.board.move(:a2, :a4)
      game.board.move(:b8, :c6)
      expect(game.board.current_player).to eq :white
      game.save_game('save_load_test')
      game.load_game('save_load_test')
      expect(game.board.current_player).to eq :white
    end

    it 'save/load enpassant' do
      game.board.move(:a2, :a4)
      game.board.move(:h8, :h6)
      game.board.move(:a4, :a5)
      game.board.move(:b7, :b5)
      expect(game.board.enpassant).to eq :b6
      game.save_game('save_load_test')
      game.load_game('save_load_test')
      expect(game.board.enpassant).to eq :b6
    end

    it 'save and load the board' do
      game.board.move(:a2, :a4)
      game.board.move(:a7, :a5)
      game.save_game('save_load_test')
      game.board.move(:b2, :b4)
      game.board.move(:b7, :b6)
      expect(game.board.get_piece(:b4).type).to include :Pawn
      game.load_game('save_load_test')
      expect(game.board.get_piece(:b4)).to be_nil
      expect(game.board.get_piece(:a4).type).to include :Pawn
    end
  end
end
