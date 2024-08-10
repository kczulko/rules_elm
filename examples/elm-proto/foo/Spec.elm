module Spec exposing (..)

import Expect
import Proto.Foo exposing (..)
import Proto.Foo.Internals_ exposing (Proto__Foo__Foo)
import Proto.Google.Protobuf.Internals_ exposing (Proto__Google__Protobuf__Timestamp)
import Proto.Com.Book.Internals_ exposing (Proto__Com__Book__Book)
import Protobuf.Types.Int64 exposing (fromInts)
import Test exposing (..)

import Json.Decode as JD
import Json.Encode as JE

expectedTimestamp = Proto__Google__Protobuf__Timestamp (fromInts 0 947203200) 0 |> Just

expectedBook = Proto__Com__Book__Book (fromInts 0 0) "someTitle" "someAuthor" |> Just

expectedFoo = Proto__Foo__Foo "" [] expectedTimestamp expectedBook

decodersTest =
    describe "Decoders usage"
        [
          test "Foo" <|
            \_  -> JD.decodeString jsonDecodeFoo """{
                                                    "details": [],
                                                    "myField": "2000-01-07",
                                                    "book": {
                                                      "isbn": 0,
                                                      "title": "someTitle",
                                                      "author": "someAuthor"
                                                    }
                                                  }""" |> Expect.equal (Ok expectedFoo)
        ]
