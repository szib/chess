require './spec/Helpers.rb'
require './lib/Chessboard.rb'

RSpec.describe Chessboard do
  generate_boards

  context '@tiles' do
    it 'has a public reader' do
      expect(chessboard).to respond_to(:tiles)
    end

    it 'has 64 tiles' do
      expect(chessboard.tiles.size).to be(64)
    end

    it 'has 16 pawns' do
      pawns = chessboard.tiles
                        .reject { |_k, v| v.nil? }
                        .select { |_k, v| v.type[1] == :Pawn }
                        .count
      expect(pawns).to be(16)
    end

    it 'has 52 pieces' do
      pieces = chessboard.tiles.each.reject { |_k, v| v.nil? }.count
      expect(pieces).to be(32)
    end
  end

  context '#add_piece' do
    it 'add a piece to the chessboard' do
      expect(chessboard.get_piece(:d4)).to be_nil
      chessboard.add_piece(:d4, Queen, :white)
      expect(chessboard.get_piece(:d4)).to be_an_instance_of(Piece)
      expect(chessboard.get_piece(:d4).type).to include :Queen
    end
  end

  context '#get_piece' do
    it 'returns nil if the tile is empty' do
      expect(chessboard.get_piece(:d3)).to be_nil
    end

    it 'returns a piece if the tile is not empty' do
      expect(chessboard.get_piece(:a2)).to be_an_instance_of(Piece)
      expect(chessboard.get_piece(:e1)).to be_an_instance_of(Piece)
      expect(chessboard.get_piece(:a2).type).to include :Pawn
      expect(chessboard.get_piece(:e1).type).to include :King
    end
  end

  context '#remove_piece' do
    it 'removes piece from the tile' do
      expect(chessboard.get_piece(:a2).type).to include :Pawn
      expect(chessboard.get_piece(:a2)).to be_an_instance_of(Piece)
      chessboard.remove_piece(:a2)
      expect(chessboard.get_piece(:a2)).to be_nil
    end
  end

  context '#display' do
    it 'returns the chessboard as string' do
      expect(chessboard.display).to include('a b c d e f g h')
    end
  end

  context '#tiles_between' do
    context 'when inclusive is false' do
      it 'returns [] if there no H/V or diagonal path' do
        expect(chessboard.tiles_between(:a1, :g8)).to be_nil
        expect(chessboard.tiles_between(:a1, :g8)).to be_nil
        expect(chessboard.tiles_between(:a8, :g1)).to be_nil
        expect(chessboard.tiles_between(:h1, :a6)).to be_nil
        expect(chessboard.tiles_between(:h8, :a3)).to be_nil
        expect(chessboard.tiles_between(:d3, :d3)).to be_nil
      end
      it 'returns correct path for horizontal move' do
        expect(chessboard.tiles_between(:a1, :a4)).to eq %i[a2 a3]
        expect(chessboard.tiles_between(:a4, :a1)).to eq %i[a2 a3]
      end
      it 'returns correct path for vertical move' do
        expect(chessboard.tiles_between(:f1, :b1)).to eq %i[c1 d1 e1]
        expect(chessboard.tiles_between(:b1, :d1)).to eq %i[c1]
      end
      it 'returns correct path for diagonal move' do
        expect(chessboard.tiles_between(:a1, :h8)).to eq %i[b2 c3 d4 e5 f6 g7]
        expect(chessboard.tiles_between(:h8, :a1)).to eq %i[b2 c3 d4 e5 f6 g7]
        expect(chessboard.tiles_between(:a8, :h1)).to eq %i[b7 c6 d5 e4 f3 g2]
        expect(chessboard.tiles_between(:h1, :a8)).to eq %i[b7 c6 d5 e4 f3 g2]
      end
    end

    context 'when inclusive is true' do
      it 'returns [] if there no H/V or diagonal path' do
        expect(chessboard.tiles_between(:a1, :g8, true)).to be_nil
        expect(chessboard.tiles_between(:a1, :g8, true)).to be_nil
        expect(chessboard.tiles_between(:a8, :g1, true)).to be_nil
        expect(chessboard.tiles_between(:h1, :a6, true)).to be_nil
        expect(chessboard.tiles_between(:h8, :a3, true)).to be_nil
        expect(chessboard.tiles_between(:d3, :d3, true)).to be_nil
      end
      it 'returns correct path for horizontal move' do
        expect(chessboard.tiles_between(:a1, :a4, true)).to eq %i[a1 a2 a3 a4]
        expect(chessboard.tiles_between(:a4, :a1, true)).to eq %i[a1 a2 a3 a4]
      end
      it 'returns correct path for vertical move' do
        expect(chessboard.tiles_between(:f1, :b1, true)).to eq %i[b1 c1 d1 e1 f1]
        expect(chessboard.tiles_between(:b1, :d1, true)).to eq %i[b1 c1 d1]
      end
      it 'returns correct path for diagonal move' do
        expect(chessboard.tiles_between(:a1, :h8, true)).to eq %i[a1 b2 c3 d4 e5 f6 g7 h8]
        expect(chessboard.tiles_between(:h8, :a1, true)).to eq %i[a1 b2 c3 d4 e5 f6 g7 h8]
        expect(chessboard.tiles_between(:a8, :h1, true)).to eq %i[a8 b7 c6 d5 e4 f3 g2 h1]
        expect(chessboard.tiles_between(:h1, :a8, true)).to eq %i[a8 b7 c6 d5 e4 f3 g2 h1]
      end
    end
  end

  context '#clear_path?' do
    context 'when there is no path' do
      it 'returns nil' do
        expect(chessboard.clear_path?(:e2, :d6)).to be_nil
      end
    end

    context 'when there is H/V path' do
      it 'it returns true for clear line' do
        expect(chessboard.clear_path?(:d3, :d6)).to be true
        expect(chessboard.clear_path?(:d6, :d3)).to be true
        expect(chessboard.clear_path?(:c3, :f3)).to be true
        expect(chessboard.clear_path?(:f3, :c3)).to be true
        expect(chessboard.clear_path?(:d3, :c3)).to be true
        expect(chessboard.clear_path?(:d3, :d4)).to be true
        expect(attackboard.clear_path?(:b4, :a5)).to be true
      end
      it 'it returns false for not clear line' do
        expect(chessboard.clear_path?(:a1, :a4)).to be false
        expect(chessboard.clear_path?(:a4, :a1)).to be false
        expect(chessboard.clear_path?(:f1, :b1)).to be false
        expect(chessboard.clear_path?(:b1, :d1)).to be false
      end
    end

    context 'when there is diagonal path' do
      it 'it returns true for clear line' do
        expect(chessboard.clear_path?(:a3, :d6)).to be true
        expect(chessboard.clear_path?(:d6, :a3)).to be true
        expect(chessboard.clear_path?(:c6, :f3)).to be true
        expect(chessboard.clear_path?(:f3, :c6)).to be true
        expect(chessboard.clear_path?(:d5, :c6)).to be true
      end
      it 'it returns false for not clear line' do
        expect(chessboard.clear_path?(:a1, :d4)).to be false
        expect(chessboard.clear_path?(:d4, :a1)).to be false
        expect(chessboard.clear_path?(:a4, :d1)).to be false
        expect(chessboard.clear_path?(:d1, :a4)).to be false
      end
    end
  end

  context '#pieces' do
    context 'without arguments' do
      it 'returns pieces' do
        expect(chessboard.pieces).to include(:c8, :f8, :a1, :f2)
      end
    end
    context 'without color argument' do
      it 'returns pieces' do
        expect(chessboard.pieces(:Bishop)).to include(:c8, :f8, :c1, :f1)
      end
    end
    context 'with color argument' do
      it 'returns pieces' do
        expect(chessboard.pieces(:Bishop, :black)).to include(:c8, :f8)
      end
    end
  end

  context '#move' do
    context 'invalid arguments' do
      it '@moved should be remain false' do
        chessboard.move(:a2, :b5)
        expect(chessboard.tiles[:a2].moved).to be false
      end
    end

    context 'moved the piece' do
      it 'moves it (no special rules)' do
        chessboard.move(:a2, :a4)
        chessboard.move(:a7, :a6)
        chessboard.move(:a1, :a3)
        expect(chessboard.tiles[:a4]).to_not be nil
        expect(chessboard.tiles[:a2]).to be nil
        expect(chessboard.tiles[:a3]).to_not be nil
        expect(chessboard.tiles[:a1]).to be nil
      end
      it '@moved should be true after moving' do
        chessboard.move(:a2, :a3)
        chessboard.move(:a7, :a6)
        expect(chessboard.tiles[:a3].moved).to be true
        expect(chessboard.tiles[:a6].moved).to be true
      end
    end

    context 'illegal move' do
      it 'does not move the piece if a piece on the path' do
        chessboard.move(:d1, :d4)
        expect(chessboard.get_piece(:d4)).to be nil
        expect(chessboard.get_piece(:d1).type).to include :Queen
      end
      it 'does move the knight even if a piece on the path' do
        chessboard.move(:b1, :a3)
        expect(chessboard.get_piece(:b1)).to be nil
        expect(chessboard.get_piece(:a3).type).to include :Knight
      end
    end
  end

  context '#check?' do
    it 'return false if not in check' do
      expect(chessboard.check?).to be false
    end
    it 'return true if in check' do
      moves = [
        %i[d2 d4],
        %i[b8 c6],
        %i[e1 d2],
        %i[h7 h6],
        %i[d2 d3],
        %i[c6 b4]
      ]
      play_board(chessboard, moves)
      expect(chessboard.check?).to be true
    end
    it 'returns check if the attacker is a Knight' do
      endgame.load_game('test_check_knight')
      expect(endgame.board.check?).to be true
    end
  end

  context 'backup&restore tiles (undo)' do
    pending('TODO')
  end

  context 'Pawn movement/capture' do
    context 'movement' do
      it 'normal movement should fail if it is a capture (white)' do
        moves = [
          %i[a2 a4],
          %i[h7 h5],
          %i[a4 a5],
          %i[a7 a5]
        ]
        play_board(chessboard, moves)
        expect(chessboard.get_piece(:a7).type).to include :Pawn
      end
      it 'normal movement should fail if it is a capture (black)' do
        moves = [
          %i[h2 h3],
          %i[a7 a5],
          %i[h3 h4],
          %i[a5 a4],
          %i[a2 a4]
        ]
        play_board(chessboard, moves)
        expect(chessboard.get_piece(:a2).type).to include :Pawn
      end
      it 'diagonal move should fail if no piece there' do
        chessboard.move(:a7, :b6)
        chessboard.move(:a2, :b3)
        expect(chessboard.get_piece(:a2).type).to include :Pawn
        expect(chessboard.get_piece(:a7).type).to include :Pawn
        expect(chessboard.get_piece(:b6)).to be nil
        expect(chessboard.get_piece(:b3)).to be nil
      end
    end

    context 'capture' do
      it 'should not fail if a piece there (white)' do
        moves = [
          %i[a2 a4],
          %i[b7 b5],
          %i[a4 b5]
        ]
        play_board(chessboard, moves)
        expect(chessboard.get_piece(:a4)).to be_nil
        expect(chessboard.get_piece(:b5).type).to include :Pawn
        expect(chessboard.get_piece(:b5).color).to eq :white
      end
      it 'should not fail if a piece there (black)' do
        moves = [
          %i[h2 h3],
          %i[a7 a5],
          %i[b2 b4],
          %i[a5 b4]
        ]
        play_board(chessboard, moves)
        expect(chessboard.get_piece(:a5)).to be_nil
        expect(chessboard.get_piece(:b4).type).to include :Pawn
        expect(chessboard.get_piece(:b4).color).to eq :black
      end
    end
  end

  context 'promotion' do
    it 'promote the Pawn to Queen' do
      promotingboard.move(:b7, :b8)
      expect(promotingboard.get_piece(:b8)).to be_promoted
      expect(promotingboard.get_piece(:b8).color).to eq :white
    end
  end

  context 'castling' do
    context 'castlingboard' do
      it 'should start with white' do
        expect(castlingboard.current_player).to be_an_instance_of Symbol
      end
    end
    context 'testing previous moves' do
      it 'should NOT castle if rook had moved' do
        moves = [
          %i[a1 b1],
          %i[c7 c6],
          %i[b1 a1],
          %i[c6 c5],
          %i[e1 c1]
        ]
        play_board(castlingboard, moves)
        expect(castlingboard.get_piece(:e1).type).to include(:King)
        expect(castlingboard.get_piece(:a1).type).to include(:Rook)
        expect(castlingboard.get_piece(:h1).type).to include(:Rook)
      end
      it 'should NOT castle if king had moved' do
        moves = [
          %i[e1 d1],
          %i[c7 c6],
          %i[d1 e1],
          %i[c6 c5],
          %i[e1 g1]
        ]
        play_board(castlingboard, moves)
        expect(castlingboard.get_piece(:e1).type).to include(:King)
        expect(castlingboard.get_piece(:h1).type).to include(:Rook)
        expect(castlingboard.get_piece(:a1).type).to include(:Rook)
      end
      it 'should castle if only the other rook had moved' do
        moves = [
          %i[a1 b1],
          %i[c7 c6],
          %i[b1 a1],
          %i[c6 c5],
          %i[e1 g1]
        ]
        play_board(castlingboard, moves)
        expect(castlingboard.get_piece(:g1).type).to include(:King)
        expect(castlingboard.get_piece(:f1).type).to include(:Rook)
      end
    end

    context 'on the left side' do
      it 'should castle if everything is OK' do
        castlingboard.move(:e1, :c1)
        expect(castlingboard.get_piece(:c1).type).to include(:King)
        expect(castlingboard.get_piece(:d1).type).to include(:Rook)
      end
      it 'should NOT castle if there is a piece between king and rook' do
        moves = [
          %i[b4 c5],
          %i[d7 c8],
          %i[c5 b4],
          %i[c8 b8],
          %i[a6 c4]
        ]
        play_board(castlingboard, moves)
        castlingboard.move(:e8, :c8)
        expect(castlingboard.get_piece(:e8).type).to include(:King)
        expect(castlingboard.get_piece(:a8).type).to include(:Rook)
      end
    end

    context 'on the right side' do
      it 'should castle if everything is OK' do
        castlingboard.move(:e1, :g1)
        expect(castlingboard.get_piece(:g1).type).to include(:King)
        expect(castlingboard.get_piece(:f1).type).to include(:Rook)
      end
      it 'should NOT castle if there is a piece between king and rook' do
        moves = [
          %i[a6 c4],
          %i[d7 c8],
          %i[g2 g3],
          %i[c8 b8],
          %i[f2 f3]
        ]
        play_board(castlingboard, moves)
        castlingboard.move(:e8, :c8)
        expect(castlingboard.get_piece(:e8).type).to include(:King)
        expect(castlingboard.get_piece(:a8).type).to include(:Rook)
      end
    end
  end

  context '#is_under_attack?' do
    it 'works with default attacker argument' do
      expect(attackboard.is_under_attack?(:a5)).to be false
      expect(attackboard.is_under_attack?(:h5)).to be true
    end

    context 'when tile is NOT under attack' do
      it 'returns false' do
        expect(attackboard.is_under_attack?(:h8, :white)).to be false
        expect(attackboard.is_under_attack?(:b6, :white)).to be false
        expect(attackboard.is_under_attack?(:h1, :black)).to be false
        expect(attackboard.is_under_attack?(:a4, :black)).to be false
      end
    end
    context 'when tile is under attack' do
      it 'returns true' do
        expect(attackboard.is_under_attack?(:a5, :white)).to be true
        expect(attackboard.is_under_attack?(:c5, :white)).to be true
        expect(attackboard.is_under_attack?(:f4, :black)).to be true
        expect(attackboard.is_under_attack?(:h4, :black)).to be true
        expect(attackboard.is_under_attack?(:b2, :white)).to be true
      end
    end

    context 'when attacker is a knight' do
      it 'returns true if tile is under attack' do
        expect(attackboard.is_under_attack?(:e4, :black)).to be true
        expect(attackboard.is_under_attack?(:g8, :black)).to be true
        expect(attackboard.is_under_attack?(:d5, :white)).to be true
      end
    end

    context 'when attacker is a pawn' do
      it 'returns true for diagonal move' do
        expect(attackboard.is_under_attack?(:a5, :white)).to be true
        expect(attackboard.is_under_attack?(:c5, :white)).to be true
        expect(attackboard.is_under_attack?(:f4, :black)).to be true
        expect(attackboard.is_under_attack?(:h4, :black)).to be true
      end
      it 'returns false for not diagonal move' do
        attackboard.move(:c3, :d5)
        attackboard.move(:f6, :d5)
        expect(attackboard.is_under_attack?(:b5, :white)).to be false
        expect(attackboard.is_under_attack?(:g4, :black)).to be false
      end
      it 'return false for two square first move' do
        expect(attackboard.is_under_attack?(:d4, :white)).to be false
        expect(attackboard.is_under_attack?(:e5, :black)).to be false
      end
    end
  end

  context 'enpassant' do
    context 'enpassantboard' do
      it 'should start with white' do
        expect(enpassantboard.current_player).to be_an_instance_of Symbol
      end
    end

    context 'when enpassant is possible' do
      it '@enpassant should be set to the tile' do
        expect(enpassantboard.enpassant).to eq :g6
        enpassantboard.move(:a2, :a4)
        expect(enpassantboard.enpassant).to eq :a3
      end
      it '@enpassant should work' do
        enpassantboard.move(:f5, :g6)
        expect(enpassantboard.get_piece(:g6).type).to include :Pawn
        expect(enpassantboard.get_piece(:g5)).to be nil
      end
      it '@enpassant should work on the other side' do
        enpassantboard.move(:h2, :h3)
        enpassantboard.move(:c5, :c4)
        enpassantboard.move(:b2, :b4)
        enpassantboard.move(:c4, :b3)
        expect(enpassantboard.get_piece(:b3).type).to include :Pawn
        expect(enpassantboard.get_piece(:b4)).to be nil
      end
    end
    context 'when enpassant is NOT possible' do
      it '@enpassant should be false' do
        expect(enpassantboard.enpassant).to eq :g6
        enpassantboard.move(:a2, :a3)
        expect(enpassantboard.enpassant).to be false
      end
      it '@enpassant should not work' do
        enpassantboard.move(:a2, :a3)
        enpassantboard.move(:e7, :e5)
        enpassantboard.move(:f5, :g6)
        expect(enpassantboard.get_piece(:f5).type).to include :Pawn
        expect(enpassantboard.get_piece(:g6)).to be nil
      end
    end
  end

  context 'serializaton' do
    it 'responds to serialize & unserialize' do
      expect(chessboard).to respond_to :serialize
      expect(chessboard).to respond_to :unserialize
    end
    it 'can be saved and restored' do
      data = enpassantboard.serialize
      b = Chessboard.new(true)
      b.unserialize(data)
      data2 = b.serialize
      expect(data).to eq data2
    end
  end

  context 'players' do
    it 'white player starts the game' do
      expect(chessboard.current_player).to eq :white
    end

    it 'current player changes with every move' do
      expect(chessboard.current_player).to eq :white
      chessboard.move(:a2, :a4)
      expect(chessboard.current_player).to eq :black
      chessboard.move(:a7, :a6)
      expect(chessboard.current_player).to eq :white
    end
  end

  context 'endgame' do
    context '#insufficient_material?' do
      it 'returns true if only two kings and a knight left' do
        endgame.load_game('test_insufficient_material_1')
        expect(endgame.board.insufficient_material?).to be true
      end
      it 'returns false if only two kings left' do
        endgame.load_game('test_insufficient_material_4')
        expect(endgame.board.insufficient_material?).to be true
      end
      it 'returns false if only two kings and a rook left' do
        endgame.load_game('test_insufficient_material_2')
        expect(endgame.board.insufficient_material?).to be false
      end
      it 'returns false if only two kings, a rook and a knight left' do
        endgame.load_game('test_insufficient_material_3')
        expect(endgame.board.insufficient_material?).to be false
      end
    end
  end

  context '#checkmate?' do
    context 'by standard move' do
      it 'returns false if king can move out of check [1]' do
        endgame.load_game('test_checkmate_1')
        expect(endgame.board.checkmate?).to be false
      end
      it 'returns true if king cannot move out of check [2]' do
        endgame.load_game('test_checkmate_2')
        expect(endgame.board.checkmate?).to be true
      end
      it 'returns true if king can move, but after move it is still under attack [4]' do
        endgame.load_game('test_checkmate_4')
        expect(endgame.board.checkmate?).to be true
      end
    end

    context 'by castling' do
      it 'returns false if king can move out [6]' do
        endgame.load_game('test_checkmate_6')
        endgame.board.move(:b4, :b1)
        expect(endgame.board.checkmate?).to be false
      end
    end

    context 'by capturing a piece' do
      it 'returns false if king can move out [3]' do
        endgame.load_game('test_checkmate_3')
        expect(endgame.board.checkmate?).to be false
      end
    end

    context 'by being saved by another piece [5]' do
      it 'returns false if a piece can move to blocking position' do
        endgame.load_game('test_checkmate_5')
        expect(endgame.board.checkmate?).to be false
      end
    end

    it 'does not change the board during mate checks' do
      endgame.load_game('test_checkmate_3')
      before_test = endgame.board.serialize
      expect(endgame.board.checkmate?).to be false
      after_test = endgame.board.serialize
      expect(before_test).to eql after_test
    end
  end

  context '#stalemate?' do
    it 'returns true when stalemate' do
      endgame.load_game('test_stalemate')
      endgame.board.move(:b8, :b7)
      expect(endgame.board.stalemate?).to be true
    end
  end
end
