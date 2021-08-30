# CraftBook::NBT

A feature-rich and complete Ruby implementation of the Named Binary Tag (NBT) format. While it is an integral part of
the broader CraftBook API, it is an independent module with no dependencies, and can be used for any purpose where
reading/writing/converting the NBT format is required.

# Features

* Intuitive and simple to use, with a user-friendly API surface
* Reads from any IO-like object
* `TagBuilder` class for easily building complete NBT documents from scratch (see example below)
* Conversion to and from JSON
* Conversion to and from SNBT (aka _stringified_ NBT), performed properly with a grammar and a lexical parser with `racc` (standard library)
* Custom formatted output in a tree structure for simple viewing NBT, or debugging for correctness
* Automatic compression detection
* Well-structured and logical inheritance tree

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'craftbook-nbt'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install craftbook-nbt

## Usage

### Require

After installing the gem, everything can be made available by requiring one file:

```ruby
require 'craftbook/nbt'
```

### Reading

For the purpose of example, we will use the de-facto [bigtest.nbt](https://raw.github.com/Dav1dde/nbd/master/test/bigtest.nbt) 
for NBT as recommended by https://wiki.vg/NBT where the specification is outlined.

To load a file (GZip and ZLib compressed files will be detected and handled automatically.):
```ruby
tag = CraftBook::NBT.read_file('/path/to/bigtest.nbt')
```

The resulting object is a `CompoundTag` instance, which is the implicit top-level container of all files. This tag
(among others) implements the `Enumerable` mixin, and exhibits typical array-like behavior, including accessing by
index for inserting/removing/fetching child elements.

If you need to read from an existing IO-like object other than a file, use the following:
```ruby
tag = CraftBook::NBT.read(io)
```

Unlike a file, compression cannot be detected from a stream, as not all streams support seeking (i.e. network). 
Furthermore, compression algorithms typically cannot start from an unknown position in a stream, and it is unsafe to
assume the position for each use. For this reason, it is up to users to apply any needed decompression wrappers over the
IO object before passing to this method. Any object that responds to `#read` and returns a String is a viable
parameter that can be used.

### Writing

Writing is just as simple:
```ruby
CraftBook::NBT.write_file('/path/to/file.nbt', compression: :gzip, level: :optimal)
```

...or if writing directly to an `IO` object or one that implements `#write`:
```ruby
compound_tag = CompoundTag.new("My First NBT Tag!")
compound_tag.push(StringTag.new("Hello", "World"))

bytes_written = CraftBook::NBT.write(STDOUT, compound_tag, compression: :zlib, level: :fastest)
```

Compression is optional, but defaults to GZip with "default" level when not specified. 

### Creating Tags

Tag creation can be done manually by creating individual tags and building the document manually, or you can use the
included `TagBuilder` class to ease in their creation.

For a complete example, we will re-create the "bigtest.nbt" mentioned above from scratch, which uses all tag types:

```ruby
include CraftBook::NBT

tb = TagBuilder.new("Level")
tb.compound('nested compound test') do

  tb.compound('egg') do
    tb.string('name', 'Eggburt')
    tb.float('value', 0.5)
  end

  tb.compound("ham") do
    tb.string('name', 'Hampus')
    tb.float('value', 0.75)
  end

  tb.int('intTest', 2147483647)
  tb.byte('byteTest', 127)
  tb.string('stringTest', "HELLO WORLD THIS IS A TEST STRING \u{c5}\u{c4}\u{d6}!")

  tb.list('listTest (long)', Tag::TYPE_LONG) do
    tb.long(nil, 11)
    tb.long(nil, 12)
    tb.long(nil, 13)
    tb.long(nil, 14)
    tb.long(nil, 15)
  end

  tb.double('doubleTest', 0.49312871321823148)
  tb.float('floatTest', 0.49823147058486938)
  tb.long('longTest', 9223372036854775807)

  tb.list('listTest (compound', Tag::TYPE_COMPOUND) do
    tb.compound(nil) do
      tb.long('created-on', 1264099775885)
      tb.string('name', 'Compound tag #0')
    end
    tb.compound(nil) do
      tb.long('created-on', 1264099775885)
      tb.string('name', 'Compound tag #1')
    end
  end

  name = 'byteArrayTest (the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...))'
  array = (0...1000).map { |n| (n * n * 255 + n * 7) % 100 }
  tb.byte_array(name, *array)
  tb.short('shortTest', 32767)
end

tag = tb.root
```

We can then compare the output:

```ruby
tag.pretty_print(STDOUT)
```

<details>
<summary>Click to Expand Output</summary>

```
TAG_Compound("Level"): 1 child
{
    TAG_Compound("nested compound test"): 12 children
    {
        TAG_Compound("egg"): 2 children
        {
            TAG_String("name"): "Eggburt"
            TAG_Float("value"): 0.5
        }
        TAG_Compound("ham"): 2 children
        {
            TAG_String("name"): "Hampus"
            TAG_Float("value"): 0.75
        }
        TAG_Int("intTest"): 2147483647
        TAG_Byte("byteTest"): 127
        TAG_String("stringTest"): "HELLO WORLD THIS IS A TEST STRING ÅÄÖ!"
        TAG_List("listTest (long)"): 5 children
        {
            TAG_Long(None): 11
            TAG_Long(None): 12
            TAG_Long(None): 13
            TAG_Long(None): 14
            TAG_Long(None): 15
        }
        TAG_Double("doubleTest"): 0.4931287132182315
        TAG_Float("floatTest"): 0.4982314705848694
        TAG_Long("longTest"): 9223372036854775807
        TAG_List("listTest (compound"): 2 children
        {
            TAG_Compound(None): 2 children
            {
                TAG_Long("created-on"): 1264099775885
                TAG_String("name"): "Compound tag #0"
            }
            TAG_Compound(None): 2 children
            {
                TAG_Long("created-on"): 1264099775885
                TAG_String("name"): "Compound tag #1"
            }
        }
        TAG_Byte_Array("byteArrayTest (the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...))"): 1 item
        TAG_Short("shortTest"): 32767
    }
}
```

</details>

Or if you prefer JSON...

```ruby
pretty = true
tag.to_json(pretty, indent: '  ')
```

<details>
<summary>Click to expand JSON output</summary>

```json

{
  "name": "Level",
  "type": 10,
  "values": [
    {
      "name": "nested compound test",
      "type": 10,
      "values": [
        {
          "name": "egg",
          "type": 10,
          "values": [
            {
              "name": "name",
              "type": 8,
              "value": "Eggburt"
            },
            {
              "name": "value",
              "type": 5,
              "value": 0.5
            }
          ]
        },
        {
          "name": "ham",
          "type": 10,
          "values": [
            {
              "name": "name",
              "type": 8,
              "value": "Hampus"
            },
            {
              "name": "value",
              "type": 5,
              "value": 0.75
            }
          ]
        },
        {
          "name": "intTest",
          "type": 3,
          "value": 2147483647
        },
        {
          "name": "byteTest",
          "type": 1,
          "value": 127
        },
        {
          "name": "stringTest",
          "type": 8,
          "value": "HELLO WORLD THIS IS A TEST STRING ÅÄÖ!"
        },
        {
          "name": "listTest (long)",
          "type": 9,
          "child_type": 4,
          "values": [
            {
              "value": 11
            },
            {
              "value": 12
            },
            {
              "value": 13
            },
            {
              "value": 14
            },
            {
              "value": 15
            }
          ]
        },
        {
          "name": "doubleTest",
          "type": 6,
          "value": 0.4931287132182315
        },
        {
          "name": "floatTest",
          "type": 5,
          "value": 0.4982314705848694
        },
        {
          "name": "longTest",
          "type": 4,
          "value": 9223372036854775807
        },
        {
          "name": "listTest (compound",
          "type": 9,
          "child_type": 10,
          "values": [
            {
              "values": [
                {
                  "name": "created-on",
                  "type": 4,
                  "value": 1264099775885
                },
                {
                  "name": "name",
                  "type": 8,
                  "value": "Compound tag #0"
                }
              ]
            },
            {
              "values": [
                {
                  "name": "created-on",
                  "type": 4,
                  "value": 1264099775885
                },
                {
                  "name": "name",
                  "type": 8,
                  "value": "Compound tag #1"
                }
              ]
            }
          ]
        },
        {
          "name": "byteArrayTest (the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...))",
          "type": 7,
          "values": [
            [
              0,
              62,
              34,
              "Removed for the sake of brevity..."
            ]
          ]
        },
        {
          "name": "shortTest",
          "type": 2,
          "value": 32767
        }
      ]
    }
  ]
}
```

</details>

...or perhaps you need to stringify it into SNBT format...

```ruby
tag.stringify
```

```
{Level:{{nested compound test:{{egg:{name:"Eggburt",value:0.5F},{ham:{name:"Hampus",value:0.75F},intTest:2147483647,byteTest:127B,stringTest:"HELLO WORLD THIS IS A TEST STRING ÅÄÖ!",listTest (long):[11L,12L,13L,14L,15L],doubleTest:0.4931287132182315,floatTest:0.4982314705848694F,longTest:9223372036854775807L,listTest (compound:[{{created-on:1264099775885L,name:"Compound tag #0"},{{created-on:1264099775885L,name:"Compound tag #1"}],byteArrayTest (the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...)):[B;0,62,...,74,6,48],shortTest:32767S}}
```

### Parsing Stringified NBT (SNBT)

For parsing SNBT, this library uses a proper lexer with a grammar file approach, taking advantage of the Racc gem, which
is part of Ruby's standard library. This allows scanning over input and tokenizing it into logical pieces to parse,
opposed to using monstrous and difficult-to-debug regular expressions.

There is only a single method call involved with parsing an arbitrary string of SNBT code: `NBT.parse_snbt`.

```ruby
snbt_string = '{name1:123,name2:"sometext1",name3:{subname1:456,subname2:"sometext2"}}'
compound = NBT.parse_snbt(snbt_string)
compound.pretty_print
```

**Output:**
```
TAG_Compound(None): 3 children
{
    TAG_Int("name1"): 123
    TAG_String("name2"): "sometext1"
    TAG_Compound("name3"): 2 children
    {
        TAG_Int("subname1"): 456
        TAG_String("subname2"): "sometext2"
    }
}
```
## Documentation

Code is fully documented using [YARD](https://yardoc.org/), which is supported by modern linters for inline documentation
in your editor, and is always available [in full at RubyDoc.info](https://www.rubydoc.info/gems/craftbook-nbt).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ForeverZer0/craftbook-nbt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ForeverZer0/craftbook-nbt/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Craftbook::Nbt project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ForeverZer0/craftbook-nbt/blob/master/CODE_OF_CONDUCT.md).
