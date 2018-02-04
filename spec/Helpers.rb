RSpec::Matchers.define :be_promoted do |_expected|
  match do |actual|
    %i[Queen Rook Knight Bishop].include? actual.type[1]
  end
end

def play_board(board, moves, show = false)
  moves.each do |m|
    board.move(m[0], m[1])
    puts board.display if show
  end
  board
end

def generate_pieces
  piece_types = [Pawn, King, Queen, Rook, Knight, Bishop]
  colors = %i[black white]
  pieces = []

  piece_types.each do |type|
    colors.each do |color|
      name = "#{color}#{type}".to_sym
      let(name) do
        Piece.new(color).extend(type)
      end
      pieces << Piece.new(color).extend(type)
    end
  end

  let(:pieces) do
    pieces
  end
end

def generate_boards
  let(:endgame) do
    Game.new
  end

  let(:empty_board) do
    Chessboard.new(true)
  end

  let(:chessboard) do
    Chessboard.new
  end

  let(:attackboard) do
    b = Chessboard.new
    moves = [
      %i[b2 b4],
      %i[g7 g5],

      %i[b1 c3],
      %i[g8 f6]
    ]
    play_board(b, moves)
    b
  end

  let(:castlingboard) do
    b = Chessboard.new
    moves = [
      %i[g1 h3],
      %i[g8 h6],

      %i[b1 a3],
      %i[b8 a6],

      %i[e2 e4],
      %i[e7 e5],

      %i[d2 d4],
      %i[d7 d5],

      %i[f1 a6],
      %i[f8 a3],

      %i[c1 h6],
      %i[c8 h3],

      %i[d1 d2],
      %i[d8 d7],

      %i[d2 b4],
      %i[b7 b6]
    ]
    play_board(b, moves)
    b
  end

  let(:promotingboard) do
    b = Chessboard.new
    moves = [
      %i[e2 e4],
      %i[a7 a6],
      %i[f1 a6],
      %i[a8 a6],
      %i[a2 a4],
      %i[a6 b6],
      %i[a4 a5],
      %i[b6 c6],
      %i[a5 a6],
      %i[c6 d6],
      %i[a6 b7],
      %i[b8 c6]
    ]
    play_board(b, moves)
    b
  end

  let(:enpassantboard) do
    b = Chessboard.new
    moves = [
      %i[f2 f4],
      %i[c7 c5],
      %i[f4 f5],
      %i[g7 g5]
    ]
    play_board(b, moves)
    b
  end
end
