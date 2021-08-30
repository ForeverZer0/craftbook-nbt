
require_relative 'lexer'

module CraftBook

  module NBT

    ##
    # Parses a stringified NBT string and creates a {CompoundTag} from it.
    #
    # @param string_nbt [String] The stringified NBT code to parse.
    #
    # @raise [SyntaxError] When the source `string_nbt` is not valid S-NBT.
    # @raise [ParseError] When a an incorrect value is specified for the type of tag it represents.
    # @raise [ArgumentError] When `string_nbt` is `nil`
    #
    # @return [CompoundTag] The parsed {CompoundTag} instance.
    #
    # @note This method is not safe to call in parallel from multiple threads.
    # @see https://minecraft.fandom.com/wiki/NBT_format#SNBT_format
    def self.parse_snbt(string_nbt)
      raise(ArgumentError, "input string cannot be nil or empty") if string_nbt.nil? || string_nbt.empty?
      @pos = 0
      @depth = 0
      lexer = Tokenizer.new
      @tokens = lexer.tokenize(string_nbt)
      parse_object(@tokens.first)
    end

    private

    def self.assert_type(expected, actual)
      raise(SyntaxError, "expected #{expected} token, got #{actual}") unless expected == actual
    end

    def self.parse_name(token)
      assert_type(:IDENTIFIER, token.type)
      assert_type(:SEPARATOR, move_next.type)
      # move_next
      token.value
    end

    def self.parse_array(name, klass)
      values = []
      loop do
        token = move_next
        case token.type
        when :END_ARRAY then break
        when :COMMA then next
        else values.push(token.value)
        end
      end

      klass.new(name, *values)
    end

    def self.move_next
      @pos += 1
      token = @tokens[@pos] || raise(SyntaxError, 'unexpected end of input')
      [:WHITESPACE, :COMMA].include?(token.type) ? move_next : token
    end

    def self.parse_list(name)
      values = []
      types = []
      loop do
        token = move_next
        case token.type
        when :COMMA then next
        when :END_ARRAY then break
        else
          types.push(token.type)
          values.push(parse_object(token))
        end
      end

      return ListTag.new(name, Tag::TYPE_END) if types.empty?
      raise(ParseError, "lists must contain only the same child type") unless types.uniq.size <= 1
      ListTag.new(name, values.first.type, *values)
    end

    def self.parse_object(token)

      name = nil
      if token.type == :IDENTIFIER
        name = parse_name(token)
        token = move_next
      end

      case token.type
      when :STRING then StringTag.new(name, token.value)
      when :INT then IntTag.new(name, token.value)
      when :DOUBLE then DoubleTag.new(name, token.value)
      when :FLOAT then FloatTag.new(name, token.value)
      when :BYTE then ByteTag.new(name, token.value)
      when :SHORT then ShortTag.new(name, token.value)
      when :LONG then LongTag.new(name, token.value)
      when :BYTE_ARRAY then parse_array(name, ByteArrayTag)
      when :INT_ARRAY then parse_array(name, IntArrayTag)
      when :LONG_ARRAY then parse_array(name, LongArrayTag)
      when :LIST_ARRAY then parse_list(name)
      when :COMPOUND_BEGIN then parse_compound(token, name)
      else raise(ParseError, "invalid token, expected object type, got :#{token.type}")
      end
    end

    def self.parse_compound(token, name)
      assert_type(:COMPOUND_BEGIN, token.type)
      compound = CompoundTag.new(name)

      loop do
        token = move_next
        break if token.type == :COMPOUND_END
        next if token.type == :COMMA
        compound.add(parse_object(token))
      end

      compound
    end
  end
end