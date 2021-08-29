
module CraftBook

  module NBT

    ##
    # Represents a collection of **unnamed** tags of the same type.
    class ListTag < ContainerTag

      ##
      # @return [Integer] One of the `Tag::TYPE_*` constants indicating the primitive type of the child tags.
      attr_reader :child_type

      ##
      # Creates a new instance of the {ListTag} class.
      #
      # @param name [String,NilClass] The name of the tag, or `nil` when unnamed.
      # @param child_type [Integer] One of the `Tag::TYPE_*` constants indicating the primitive type of the child tags.
      # @param values [Array<Tag>] Zero or more values to add during initialization.
      def initialize(name, child_type, *values)
        super(TYPE_LIST, name, *values)
        @child_type = Integer(child_type)
      end

      ##
      # @return [String] the NBT tag as a formatted and human-readable string.
      def to_s
        "TAG_List(#{@name ? "\"#{@name}\"" : 'None'}): #{size} #{size == 1 ? 'child' : 'children'}"
      end

      ##
      # @return [String] the NBT tag as an SNBT string.
      def stringify
        "#{snbt_prefix}[#{map(&:stringify).join(',')}]"
      end

      ##
      # @return [Hash{Symbol => Object}] the hash-representation of this object.
      def to_h
        children = @values.map do |obj|
          child = obj.to_h
          child.delete(:name)
          child.delete(:type)
          child
        end
        { name: @name, type: @type, child_type: @child_type, values: children }
      end

      protected

      def parse_hash(hash)
        @values = []
        values = hash[:values]
        child_type = hash[:child_type]
        raise(ParseError, "invalid array") unless values.is_a?(Array)
        raise(ParseError, "invalid child type") unless !child_type.nil? & child_type.between?(TYPE_END, TYPE_LONG_ARRAY)

        klass = Tag.class_from_type(child_type)
        values.each do |value|
          child = klass.new(nil)
          child.send(:parse_hash, value)
          push(child)
        end
      end
    end
  end
end