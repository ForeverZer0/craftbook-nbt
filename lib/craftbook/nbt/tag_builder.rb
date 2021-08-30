
module CraftBook
  module NBT

    ##
    # Provides an intuitive and simplified way of building a complete NBT document from scratch, using only basic
    # values without the need of creating intermediate {Tag} objects.
    class TagBuilder

      ##
      # @return [CompoundTag] the implicit top-level {CompoundTag} that the {TagBuilder} is creating.
      attr_reader :root

      ##
      # Creates a new instance of the {TagBuilder} class.
      # @param name [String,NilClass] the name of the implicit top-level {CompoundTag} being created.
      def initialize(name)
        @root = CompoundTag.new(name)
        @stack = []
      end

      ##
      # Creates a new {TagBuilder} instance within a block, returning the completed {CompoundTag} when the block
      # closes.
      #
      # @param name [String,NilClass] the name of the implicit top-level {CompoundTag} that the {TagBuilder} is creating.
      # @return [CompoundTag] The resulting {CompoundTag} that was created.
      # @raise [LocalJumpError] when called without a block.
      def self.create(name)
        raise(LocalJumpError, 'block required') unless block_given?
        builder = new(name)
        yield builder
        builder.result
      end

      ##
      # Creates a new {TagBuilder} instance from an existing {CompoundTag}.
      # @param compound_tag [CompoundTag] An existing {CompoundTag} instance.
      # @return [TagBuilder] A newly created {TagBuilder}.
      # @raise [TypeError] when `compound_tag` is not a {CompoundTag}.
      def self.from(compound_tag)
        raise(TypeError, "#{compound_tag} is not a #{CompoundTag}") unless compound_tag.is_a?(CompoundTag)

        builder = allocate
        builder.instance_variable_set(:@root, compound_tag)
        builder.instance_variable_set(:@stack, Array.new)
        builder
      end

      ##
      # Adds an existing {Tag} instance as a child to the current node.
      # @param tag [Tag] The {Tag} object to add.
      #
      # @yieldparam builder [TagBuilder] Yields the {TagBuilder} instance to the block.
      # @return [self]
      # @raise [TypeError] when `tag` is not a {Tag} instance or `nil`.
      def add(tag)
        raise(TypeError, "tag cannot be nil") unless tag.is_a?(Tag)

        root = @stack.empty? ? @root : @stack.last

        if root.is_a?(CompoundTag) && tag.name.nil?
          warn("direct children of Compound tags must be named")
        elsif root.is_a?(ListTag) && tag.name
          tag.name = nil
        end
        root.push(tag)
        self
      end

      alias_method :<<, :add
      alias_method :push, :add

      ##
      # Creates a {ByteTag} from the specified value, and adds it to the current node.
      # @param value [Integer] The value of the tag.
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @return [self]
      def byte(name, value)
        add(ByteTag.new(name, Integer(value)))
      end

      ##
      # Creates a {ShortTag} from the specified value, and adds it to the current node.
      # @param value [Integer] The value of the tag.
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @return [self]
      def short(name, value)
        add(ShortTag.new(name, Integer(value)))
      end

      ##
      # Creates a {IntTag} from the specified value, and adds it to the current node.
      # @param value [Integer] The value of the tag.
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @return [self]
      def int(name, value)
        add(IntTag.new(name, Integer(value)))
      end

      ##
      # Creates a {LongTag} from the specified value, and adds it to the current node.
      # @param value [Integer] The value of the tag.
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @return [self]
      def long(name, value)
        add(LongTag.new(name, Integer(value)))
      end

      ##
      # Creates a {FloatTag} from the specified value, and adds it to the current node.
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @param value [Float] The value of the tag.
      # @return [self]
      def float(name, value)
        add(FloatTag.new(name, Float(value)))
      end

      ##
      # Creates a {DoubleTag} from the specified value, and adds it to the current node.
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @param value [Float] The value of the tag.
      # @return [self]
      def double(name, value)
        add(DoubleTag.new(name, Float(value)))
      end

      ##
      # Creates a {StringTag} from the specified value, and adds it to the current node.
      # @param value [String,Object] The value of the tag.
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @return [self]
      def string(name, value)
        add(StringTag.new(name, String(value)))
      end

      ##
      # Creates a {ByteArrayTag} from the specified values, and adds it to the current node.
      # @param values [Array<Integer>,Enumerable] The child values of the tag.
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @return [self]
      def byte_array(name, *values)
        add(ByteArrayTag.new(name, *values))
      end

      ##
      # Creates a {IntArrayTag} from the specified values, and adds it to the current node.
      # @param values [Array<Integer>,Enumerable] The child values of the tag.
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @return [self]
      def int_array(name, *values)
        add(IntArrayTag.new(name, *values))
      end

      ##
      # Creates a {LongArrayTag} from the specified values, and adds it to the current node.
      # @param values [Array<Integer>,Enumerable] The child values of the tag.
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @return [self]
      def long_array(name, *values)
        add(LongArrayTag.new(name, *values))
      end

      ##
      # Creates a {ListTag} from the specified value, and adds it to the current node.
      #
      # @param child_type [Integer] One of the `Tag::TYPE_*` constants indicating the type of children in this tag.
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @param children [Array<Tag>,Enumerable] The child values of the tag.
      #
      # @overload list(child_type, name = nil, children =nil, &block)
      #   When called with a block, creates a new node that is pushed onto the stack. All tags created within the
      #   block will be added to this new scope. The node is closed when the block exits.
      #   @yield Yields nothing to the block.
      #
      # @overload list(child_type, name = nil, children =nil)
      #   When called without a block, all values to be included must be present in the `children` argument.
      #
      # @return [self]
      def list(name, child_type, *children)
        list = ListTag.new(name, child_type, *children)

        if block_given?
          @stack.push(list)
          yield
          @stack.pop
        end

        add(list)
      end

      ##
      # Creates a {CompoundTag} from the specified value, and adds it to the current node.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when adding to a {ListTag} node.
      # @param children [Array<Tag>,Enumerable] The child values of the tag.
      #
      # @overload compound(name = nil, children =nil, &block)
      #   When called with a block, creates a new node that is pushed onto the stack. All tags created within the
      #   block will be added to this new scope. The node is closed when the block exits.
      #   @yield Yields nothing to the block.
      #
      # @overload compound(name = nil, children =nil)
      #   When called without a block, all values to be included must be present in the `children` argument.
      #
      # @return [self]
      def compound(name, *children)
        compound = CompoundTag.new(name, *children)
        
        if block_given?
          @stack.push(compound)
          yield self
          @stack.pop
        end

        add(compound)
      end
    end
  end
end
