
module CraftBook
  module NBT

    ##
    # @abstract
    # Abstract base class for tag types that can contain other {Tag} objects as children.
    class ContainerTag < EnumerableTag

      ##
      # Creates a new instance of the {EnumerableTag} class.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param values [Array<Tag>] Zero or more values to add during initialization.
      def initialize(type, name, *values)
        super(type, name, *values)
      end

      ##
      # @return [Hash{Symbol => Object}] the hash-representation of this object.
      def to_h
        a = @values.map { |child| child.to_h }
        { name: @name, type: @type, values: a }
      end

      ##
      # Outputs the NBT tag as a formatted and tree-structured string.
      #
      # @param io [IO,#puts] An IO-like object that responds to #puts.
      # @param level [Integer] The indentation level.
      # @param indent [String] The string inserted for each level of indent.
      #
      # @return [void]
      def pretty_print(io = STDOUT, level = 0, indent = '    ')
        space = indent * level
        io.puts(space + to_s)
        io.puts(space + '{')
        each { |child| child.pretty_print(io, level + 1, indent) }
        io.puts(space + '}')
      end

      protected

      def parse_hash(hash)
        @values = []
        values = hash[:values]
        raise(ParseError, "invalid array") unless values.is_a?(Array)
        values.each do |value|
          raise(ParseError, "expected JSON object") unless value.is_a?(Hash)
          push(Tag.from_hash(value))
        end
      end
    end
  end
end