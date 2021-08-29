
module CraftBook

  module SNBT

    def self.parse(text)
      json = JSON.parse(text)
      raise(ParseError, 'invalid SNBT format, expected Object at top-level') unless json.is_a?(Hash)

      tag = CompoundTag.new(nil)
      json.each_pair do |name, value|

        result = nil




      end
    end

    private



    BYTE_ARRAY_NAME = "B;"
    INT_ARRAY_NAME  = "I;"
    LONG_ARRAY_NAME = "L;"

    private

    def self.parse_tag(name, value)
      case value
      when Array then parse_list(name, value)
      when Hash then parse_compound(name, value)
      when Integer then IntTag.new(name, value)
      when Float then DoubleTag.new(name, value)
      when  /^(true|false)$/ then ByteTag.new(name, 'true'.casecmp?(value) ? 1 : 0)
      when /^([0-9]+)[Bb]$/ then ByteTag.new(name, $1.to_i)
      when /^([0-9]+)[Ss]$/ then ShortTag.new(name, $1.to_i)
      when /^([0-9]+)[Ll]$/ then LongTag.new(name, $1.to_i)
      when /^([0-9]+)[Ff]$/ then FloatTag.new(name, $1.to_f)


      else

        puts value.class
        p [name, value]
        puts

      end
    end

    def self.parse_list(name, value)

    end

    def self.parse_compound(name, value)

    end
  end
end