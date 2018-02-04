def other_color(color)
  return :white if color == :black
  return :black if color == :white
  nil
end

def is_a_valid_tile?(tile)
  return false if tile.nil?
  return true if /^[a-h]{1}[1-8]{1}$/.match?(tile.to_s)
  false
end

def enpassant_tiles(tile)
  r = []
  r << "#{(tile.to_file.ord - 1).chr}#{tile.to_rank}".to_sym
  r << "#{(tile.to_file.ord + 1).chr}#{tile.to_rank}".to_sym
  r.select { |t| is_a_valid_tile?(t) == true }
end

class Symbol
  def to_file
    return nil unless is_a_valid_tile?(to_s)
    to_s.split('')[0]
  end

  def to_rank
    return nil unless is_a_valid_tile?(to_s)
    to_s.split('')[1].to_i
  end
end

module Serializable
  def serialize
    obj = {}
    obj[:@color] = instance_variable_get(:@color)
    obj[:@type] = instance_variable_get(:@type)[1]
    obj[:@moved] = instance_variable_get(:@moved)
    JSON.dump obj
  end

  def unserialize(s)
    obj = JSON.parse(s, symbolize_names: true)
    instance_variable_set(:@color, obj[:@color].to_sym)
    moved = obj[:@moved]
    instance_variable_set(:@moved, moved)
    extend(eval(obj[:@type]))
  end
end

module ChessboardHelpers
  attr_reader :backup
  def reset_board
    @tiles = {}
    ('a'..'h').each do |f|
      (1..8).each do |r|
        @tiles["#{f}#{r}".to_sym] = nil
      end
    end
    @enpassant = nil
    @current_player = :white
  end

  def serialize
    obj = {}
    obj[:tiles] = {}
    @tiles.each.reject { |tile| tile[1].nil? }
          .each { |tile| obj[:tiles][tile[0]] = tile[1].serialize }
    obj[:enpassant] = @enpassant
    obj[:current_player] = @current_player
    JSON.dump obj
  end

  def unserialize(string)
    reset_board
    obj = JSON.parse(string, symbolize_names: true)

    obj[:tiles].each do |tile|
      p = Piece.new(:white)
      p.unserialize(tile[1])
      @tiles[tile[0].to_sym] = p
    end

    @enpassant = is_a_valid_tile?(obj[:enpassant]) ? obj[:enpassant].to_sym : false
    @current_player = obj[:current_player].to_sym
  end

  def next_player
    @current_player = other_color(@current_player)
  end

  def add_piece(tile, piece, color)
    return nil unless is_a_valid_tile?(tile)
    piece = Piece.new(color).extend(piece)
    piece.init
    @tiles[tile] = piece
    piece
  end

  def get_piece(tile)
    return @tiles[tile] if is_a_valid_tile?(tile)
  end

  def remove_piece(tile)
    @tiles[tile] = nil if is_a_valid_tile?(tile)
    nil
  end

  def pieces(type = :Piece, color = nil)
    pieces = @tiles.reject { |_k, v| v.nil? }
                   .select { |_k, v| v.type.include?(type) }
    return pieces if color.nil?
    pieces.select { |_k, v| v.color == color }
  end

  def empty_tile_at?(tile)
    if get_piece(tile).nil?
      true
    else
      false
    end
  end

  def own_piece?(tile)
    return false if empty_tile_at?(tile)
    get_piece(tile).color == @current_player
  end

  def opponents_piece?(tile)
    return false if empty_tile_at?(tile)
    get_piece(tile).color == other_color(@current_player)
  end

  def undo_last_move
    unserialize(@backup)
  end

  def display
    rows = []
    hr = ("\u2500" * 8).split('').join("\u253c")
    header = ['   a b c d e f g h', "  \u250c#{("\u2500" * 8).split('').join("\u252c")}\u2510"].join("\n")
    footer = ["  \u2514#{("\u2500" * 8).split('').join("\u2534")}\u2518", '   a b c d e f g h'].join("\n")
    8.downto(1).each do |r|
      rows << ('a'..'h').map { |f| get_piece("#{f}#{r}".to_sym).to_s }
                        .map { |x| x.empty? ? ' ' : x }
                        .join("\u2502")
    end
    rows.map!.with_index { |row, i| "#{8 - i} \u2502#{row}\u2502 #{8 - i}" }
    [header, rows.join("\n  \u251c#{hr}\u2524\n"), footer].join("\n")
  end

  def to_s
    # for testing only
    r = []
    @tiles.each do |k, v|
      r << "\nrow #{k.to_s[0]}" if k.to_s.split('')[1] == '1'
      r << "#{k}>#{v.class}"
    end
    r.join(', ')
  end

  def backup_tiles
    @backup = serialize
  end

  private

  def print_check
    puts "   *****************"
    puts "   ****  CHECK  ****"
    puts "   *****************"
  end

  def place_pieces
    ('a'..'h').each do |f|
      add_piece("#{f}2".to_sym, Pawn, :white)
      add_piece("#{f}7".to_sym, Pawn, :black)
    end

    # rook
    add_piece(:a1, Rook, :white)
    add_piece(:h1, Rook, :white)
    add_piece(:a8, Rook, :black)
    add_piece(:h8, Rook, :black)

    # knight
    add_piece(:b1, Knight, :white)
    add_piece(:g1, Knight, :white)
    add_piece(:b8, Knight, :black)
    add_piece(:g8, Knight, :black)

    # bishop
    add_piece(:c1, Bishop, :white)
    add_piece(:f1, Bishop, :white)
    add_piece(:c8, Bishop, :black)
    add_piece(:f8, Bishop, :black)

    # royals
    add_piece(:d1, Queen, :white)
    add_piece(:e1, King, :white)
    add_piece(:d8, Queen, :black)
    add_piece(:e8, King, :black)
  end
end
