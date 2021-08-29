
module CraftBook
  module NBT

    ##
    # @abstract
    # Abstract base class for all tag types.
    class Tag

      ##
      # Not a concrete tag, implies the end of a Compound tag during serialization.
      TYPE_END        = 0x00

      ##
      # A signed 8-bit integer in the range of `-128` to `127` inclusive.
      TYPE_BYTE       = 0x01

      ##
      # A signed 16-bit integer in the range of `-32768` to `32767` inclusive.
      TYPE_SHORT      = 0x02

      ##
      # A signed 32-bit integer in the range of `-2147483648` to `2147483647` inclusive.
      TYPE_INT        = 0x03

      ##
      # A signed 64-bit integer in the range of `-9223372036854775808` and `9223372036854775807` inclusive.
      TYPE_LONG       = 0x04

      ##
      # An IEEE-754 single-precision floating point number (NaN possible).
      TYPE_FLOAT      = 0x05

      ##
      # An IEEE-754 double-precision floating point number (NaN possible).
      TYPE_DOUBLE     = 0x06

      ##
      # A contiguous collection of signed 8-bit integers in the range of `-128` to `127` inclusive.
      TYPE_BYTE_ARRAY = 0x07

      ##
      # A UTF-8 encoded string.
      TYPE_STRING     = 0x08

      ##
      # A collection of **unnamed** tags of the same type.
      TYPE_LIST       = 0x09

      ##
      # A collection of **named** tags, order not guaranteed.
      TYPE_COMPOUND   = 0x0A

      ##
      # A contiguous collection of signed 32-bit integers in the range of `-2147483648` to `2147483647` inclusive.
      TYPE_INT_ARRAY  = 0x0B

      ##
      # A contiguous collection of signed 64-bit integers in the range of `-9223372036854775808`
      # and `9223372036854775807` inclusive.
      TYPE_LONG_ARRAY = 0x0C

      ##
      # @return [Integer] one of the `TYPE_*` constants to describe the primitive NBT type.
      attr_reader :type

      ##
      # @return [String?] the name of the tag, or `nil` if unnamed.
      attr_reader :name

      ##
      # Creates a new instance of the {Tag} class.
      # @param type [Integer] One of the `TAG_*` constants indicating the primitive tag type.
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      def initialize(type, name)
        @type = type || raise(TypeError, 'type cannot be nil')
        @name = name
      end

      ##
      # Sets the name of the tag.
      # @param value [String] The value to set the tag name as.
      # @return [String?] The name of the tag.
      def name=(value)
        @name = value.nil? ? nil : String(value)
      end

      ##
      # @abstract
      # @return [Hash{Symbol => Object}] the hash-representation of this object.
      def to_h
        { name: @name, type: @type }
      end

      ##
      # Retrieves the NBT tag in JavaScript Object Notation (JSON) format.
      #
      # @param pretty [Boolean] Flag indicating if output should be formatted in a more human-readable structure.
      # @param opts [{Symbol=>String}] Options for how the output is formatted when using `pretty` flag.
      # @option opts [String] indent: ('  ') The string used for indenting.
      # @option opts [String] space: (' ') The string used for spaces.
      # @option opts [String] array_nl: ("\n") The string used for newlines between array elements.
      # @option opts [String] object_nl: ("\n") The string used for newlines between objects.
      #
      # @return [String] the JSON representation of this object.
      def to_json(pretty = false, **opts)
        pretty ? JSON.pretty_generate(to_h.compact, **opts) : to_h.compact.to_json
      end

      ##
      # Parses a {Tag} object from a JSON string.
      #
      # @param json [String] A string in JSON format.
      # @return [Tag] The deserialized {Tag} instance.
      def self.parse(json)
        hash = JSON.parse(json, symbolize_names: true )
        raise(ParseError, 'invalid format, expected object') unless hash.is_a?(Hash)
        from_hash(hash)
      end

      ##
      # @abstract
      # @raise [NotImplementedError] Method must be overridden in derived classes.
      # @return [String] the NBT tag as an SNBT string.
      def stringify
        raise(NotImplementedError, "#{__method__} must be implemented in derived classes")
      end

      alias_method :snbt, :stringify
      alias_method :to_hash, :to_h
      alias_method :to_str, :to_s

      ##
      # Retrieves the NBT tag as a formatted and tree-structured string.
      #
      # @param indent [String] The string inserted for each level of indent.
      #
      # @see pretty_print
      # @return [String] The NBT string as a formatted string.
      def pretty(indent = '    ')
        io = StringIO.new
        pretty_print(io, 0, indent)
        io.string
      end

      ##
      # Outputs the NBT tag as a formatted and tree-structured string.
      #
      # @param io [IO,#puts] An IO-like object that responds to #puts.
      # @param level [Integer] The indentation level.
      # @param indent [String] The string inserted for each level of indent.
      #
      # @see pretty
      # @return [void]
      def pretty_print(io = STDOUT, level = 0, indent = '    ')
        io.puts(indent * level + self.to_s)
      end

      protected

      def snbt_prefix
        @name ? "#{@name}:" : ''
      end

      def self.class_from_type(type)
        case type
        when Tag::TYPE_BYTE then ByteTag
        when Tag::TYPE_SHORT then ShortTag
        when Tag::TYPE_INT then IntTag
        when Tag::TYPE_LONG then LongTag
        when Tag::TYPE_FLOAT then FloatTag
        when Tag::TYPE_DOUBLE then DoubleTag
        when Tag::TYPE_BYTE_ARRAY then ByteArrayTag
        when Tag::TYPE_STRING then StringTag
        when Tag::TYPE_LIST then ListTag
        when Tag::TYPE_COMPOUND then CompoundTag
        when Tag::TYPE_INT_ARRAY then IntArrayTag
        when Tag::TYPE_LONG_ARRAY then LongArrayTag
        else raise(ParseError, "invalid tag type")
        end
      end

      def self.from_hash(hash)

        name = hash[:name]
        type = hash[:type]
        raise(ParseError, "invalid type") unless !type.nil? & type.between?(TYPE_END, TYPE_LONG_ARRAY)

        tag = class_from_type(type).allocate
        tag.instance_variable_set(:@name, name)
        tag.instance_variable_set(:@type, type)
        tag.send(:parse_hash, hash)
        tag
      end
    end
  end
end