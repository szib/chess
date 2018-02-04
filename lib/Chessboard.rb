require 'json'
require './lib/Helpers.rb'
require './lib/Pieces.rb'

class Chessboard
  attr_reader :tiles, :enpassant, :current_player

  def initialize(empty_board = false)
    extend ChessboardHelpers
    reset_board
    place_pieces unless empty_board
    backup_tiles
  end

  def tiles_between(first, last, inclusive = false)
    return nil if first == last
    return nil unless is_a_valid_tile?(first) && is_a_valid_tile?(last)

    tiles = [first, last].sort!
    first = tiles[0]
    last = tiles[1]
    path = []

    if first.to_file == last.to_file && first.to_rank != last.to_rank
      path = (first..last).select { |x| x.to_file == first.to_file }
    elsif first.to_file != last.to_file && first.to_rank == last.to_rank
      path = (first..last).select { |x| x.to_rank == first.to_rank }
    else
      reverse_diagonal = first.to_rank > last.to_rank
      first.to_file.upto(last.to_file).with_index do |f, fi|
        if reverse_diagonal == true
          first.to_rank.downto(last.to_rank).with_index do |r, ri|
            path << "#{f}#{r}".to_sym if fi == ri
          end
        else
          first.to_rank.upto(last.to_rank).with_index do |r, ri|
            path << "#{f}#{r}".to_sym if fi == ri
          end
        end
      end
    end

    return nil if path & tiles != tiles
    return [] if path.last != last
    path -= tiles unless inclusive
    path
  end

  def clear_path?(tile1, tile2)
    path = tiles_between(tile1, tile2)
    return nil if path.nil?
    path.all? { |x| empty_tile_at?(x) }
  end

  def is_under_attack?(tile, attacker = other_color(@current_player))
    return false if pieces(:Piece, attacker)
                    .select { |pieces_tile, p| p.move_set(pieces_tile).include?(tile) }
                    .select { |pieces_tile, p| p.type.include?(:Knight) ? true : clear_path?(pieces_tile, tile) }
                    .reject { |t, p| p.type.include?(:Pawn) && t.to_file == tile.to_file }
                    .empty?
    true
  end

  def check?(color = @current_player)
    is_under_attack?(pieces(:King, color).keys[0])
  end

  def stalemate?
    return false if check?

    tiles_backup = serialize
    my_pieces = pieces(:Piece, @current_player)

    my_pieces.each do |arr|
      from = arr[0]
      piece = arr[1]

      moves = piece.move_set(from)

      moves.each do |to|
        move(from, to, true)
        unless check?
          unserialize(tiles_backup)
          return false
        end
        unserialize(tiles_backup)
      end
    end
    true
  end

  def checkmate?(color = @current_player)
    tiles_backup = serialize
    my_pieces = pieces(:Piece, color)

    my_pieces.each do |arr|
      from = arr[0]
      piece = arr[1]

      moves = piece.move_set(from)
      moves += piece.castling_move_set(from) if piece.type.include?(:King)

      moves.each do |to|
        move(from, to, true)
        unless check?
          unserialize(tiles_backup)
          return false
        end
        unserialize(tiles_backup)
      end
    end
    true
  end

  def is_it_a_castling?(from, to)
    piece = get_piece(from)
    return false unless piece.type.include?(:King)
    return true if (to.to_file.ord - from.to_file.ord).abs == 2
    false
  end

  def calc_rooks_movement(from, to)
    if from.to_file > to.to_file
      rook_from_file = 'a'
      rook_to_file = 'd'
    else
      rook_from_file = 'h'
      rook_to_file = 'f'
    end

    rook_from = "#{rook_from_file}#{from.to_rank}".to_sym
    rook_to = "#{rook_to_file}#{from.to_rank}".to_sym
    [rook_from, rook_to]
  end

  def castling_is_possible?(from, to)
    king = get_piece(from)
    return false if king.moved

    path_under_attack = tiles_between(from, to)
                        .slice(1..-1)
                        .any? { |t| is_under_attack?(t, other_color(king.color)) }
    return false if path_under_attack

    rooks_movement = calc_rooks_movement(from, to)
    rook = get_piece(rooks_movement[0])

    return false if rook.nil?
    return false if rook.moved
    return false unless clear_path?(from, rooks_movement[0])
    true
  end

  def do_castling(from, to)
    backup_tiles
    move_the_piece(from, to) # king
    rooks_movement = calc_rooks_movement(from, to)
    move_the_piece(rooks_movement[0], rooks_movement[1]) # rook
  end

  def move_the_piece(from, to)
    @tiles[from].moved = true
    @tiles[to] = get_piece(from)
    @tiles[from] = nil
    @tiles["#{to.to_file}#{from.to_rank}".to_sym] = nil if @enpassant == to
  end

  def legal_move?(from, to)
    piece = get_piece(from)
    if own_piece?(from) && (empty_tile_at?(to) || opponents_piece?(to))

      if piece.type.include?(:Pawn)
        if empty_tile_at?(to)
          return false if piece.moved && (from.to_rank - to.to_rank).abs != 1
          unless @enpassant == to || opponents_piece?(to)
            return false if from.to_file != to.to_file
          end
        else
          return false if from.to_file == to.to_file
        end
      elsif piece.type.include?(:King) && is_it_a_castling?(from, to)
        return castling_is_possible?(from, to)
      elsif !piece.type.include?(:Knight)
        return false unless clear_path?(from, to)
      end

      if piece.move_set(from).include?(to)
        return true
      else
        return false
      end
    end
  end

  def move(from, to, virtual_move = false)
    if legal_move?(from, to)
      if is_it_a_castling?(from, to)
        do_castling(from, to) if castling_is_possible?(from, to)
      else
        backup_tiles
        move_the_piece(from, to)
      end

      unless virtual_move
        if check?
          print_check
          undo_last_move
        else
          piece = get_piece(to)
          if piece.respond_to?(:promote)
            @tiles[to] = piece.promote(to) if piece.has_reached_the_other_side?(to)
            @enpassant = if (from.to_rank - to.to_rank).abs == 2
                           "#{to.to_file}#{(from.to_rank + to.to_rank) / 2}".to_sym
                         else
                           false
            end
          end
          print_check if check?(other_color(@current_player))
          next_player
        end
      end
    else
      puts "\n\nIllegal move: #{from} => #{to}\n\n" unless virtual_move
    end
  end

  def insufficient_material?
    all_pieces = pieces
    return true if all_pieces.length <= 2 && all_pieces.all? { |_t, piece| piece.type.include?(:King) }
    all_pieces.length == 3 && all_pieces.any? { |_t, piece| piece.type.include?(:Knight) }
  end

  def game_over?
    return { reason: :insufficient_material } if insufficient_material?
    return { reason: :checkmate, winner: other_color(@current_player) } if checkmate?
    false
  end
end
