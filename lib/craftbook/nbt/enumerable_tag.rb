
module CraftBook

  module NBT
    ##
    # @abstract
    # Abstract base class for tags that can be enumerated.
    class EnumerableTag < Tag

      include Enumerable

      ##
      # Creates a new instance of the {EnumerableTag} class.
      #
      # @param type [Integer] One of the `TAG_*` constants indicating the primitive tag type.
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param values [Array<Object>] Zero or more values to add during initialization.
      def initialize(type, name, *values)
        super(type, name)
        @values = Array.new
        values.each { |value| push(value) }
      end

      ##
      # Appends a value as a child of this instance.
      #
      # @param child [Object] The value to add.
      #
      # @raise [TypeError] When `child` is `nil`.
      # @return [Object] the value that was added.
      def push(child)
        @values.push(validate(child))
      end

      ##
      # @overload each(&block)
      #   When called with a block, yields each child element to the block before returning `self`.
      #   @yieldparam child [Object] Yields a child element to the block.
      #   @return [self]
      #
      # @overload each
      #   When called without a block, returns an Enumerator object for this instance.
      #   @return [Enumerable]
      def each
        return enum_for(__method__) unless block_given?
        @values.compact.each { |child| yield child }
        self
      end

      ##
      # @return [Hash{Symbol => Object}] the hash-representation of this object.
      def to_h
        { name: @name, type: @type, values: @values }
      end

      ##
      # @return [Integer] the number of child elements.
      def size
        @values.compact.size
      end

      ##
      # Retrieves the child at the given `index`, or `nil` if index is out of bounds.
      #
      # @param index [Integer] The zero-based index of the child element to retrieve.
      # @return [Object] The element, or `nil` if index was out of bounds.
      def [](index)
        @values[index]
      end

      ##
      # Sets the child element at the given `index`.
      #
      # @param index [Integer] The zero-based index of the child element to set.
      # @param value [Object] The value to set.
      #
      # @return [Object] the value that was passed in.
      #
      # @raise [TypeError] When `value` is `nil`.
      # @note Unlike normal Array object, when index is beyond the bounds of the collection, it will not insert `nil`
      #   elements to fill the space, the new item is simply appended to the end of the collection.
      def []=(index, value)
        validate(value)
        @values[index] = value
      end

      alias_method :<<, :push
      alias_method :add, :push
      alias_method :length, :size

      protected

      def validate(child)
        raise(TypeError, 'enumerable tag cannot contain nil') unless child
        child
      end

      def parse_hash(hash)
        @values = []
        values = hash[:values]
        raise(ParseError, "invalid array") unless values.is_a?(Array)
        values.each { |value| push(value) }
      end
    end
  end
end