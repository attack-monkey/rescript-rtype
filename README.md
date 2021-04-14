Rtype
========

Rtype is a super-simple way of decoding unknown json.

How it works
------------

Let's create a value that the type system is unaware of...

```rescript

%%raw(`const unknown = { greeting: "hello world" }`)
@val external unknown: 'a = "unknown"

```

Using Rtype (short for for Runtime Type), we can match an unknown value against a given type.

We start by creating the type that we are looking for. We'll call this the decoder-type.

```rescript

type decoder = {
  greeting: string
}

```

We can now create the actual decoder using Rtype.  
Note how similar the decoder is to the actual decoder-type above.  
Also the decoder has the same type as the decoder-type.  

```rescript
open Rtype // Opening Rtype gives access to the match function, as well as common decoders

let decoder: decoder = {
  greeting: string
}

```

Simply pass the unknown value into `match(decoder)` and `switch` on the `outcome`.  
If the value matches the decoder, the decoder-type type is inferred.

```rescript

unknown
  -> match(decoder)
  -> outcome => switch outcome {
    | Some(value) => Js.log(value.greeting)
    | None => Js.log(":(")
    }

```

Built in decoders
-----------------

We can build decoders with
- string, int, float, bool, as well as
- array(...) where ... can be any other decoder
- dict(...) where ... can be any other decoder
- as well as...
- gt, gte, lt, lte => eg. gt(10.0) will match if it gets a float greater than 10
- And Tuple and Record decoders can be built from all of the above.

Eg. Matching a dictionary
-------------------------

```rescript

type compileTimeCat = { name: string }
type compileTimeDictionary = Js.Dict.t<compileTimeCat>

let runTimeTypeDictionary: compileTimeDictionary = dict({ name: string })

// create a value unknown. The type system is unaware of the actual type.
%%raw(`const unknown2 = { charlie: { name: "charlie" }}`)
@val external unknown2: 'a = "unknown2"

unknown2 -> match(runTimeTypeDictionary) -> v => switch v {
| Some(thing) => switch Js.Dict.get(thing, "charlie") {
  | Some(cat) => Js.log(cat.name)
  | None => Js.log(":(")
  }
| None => Js.log(">:(")
}

```

Eg. Matching a tuple
-------------------------

```rescript

type myTuple = (string, int, bool)

let myTuple: myTuple = (string, int, bool)

%%raw(`const unknown3 = ["hi", 7, true]`)
@val external unknown3: 'a = "unknown3"

unknown3
  -> match(myTuple)
  -> outcome => switch outcome {
    | Some(str, _, _) => Js.log(str ++ " there") // hi there
    | None => Js.log(":(")
    }

```

Matching on literals
--------------------

```rescript

"hello world"
  -> match("hello world")
  -> outcome => switch outcome {
    | Some(greeting) => Js.log(greeting) // hello world
    | None => Js.log(":(")
    }

```