module Spec exposing (..)

import Expect
import Proto.Foo exposing (..)
import Proto.Foo.Internals_ exposing (Proto__Foo__Foo)
import Proto.Google.Protobuf.Internals_ exposing (Proto__Google__Protobuf__Timestamp)
import Proto.Com.Book.Internals_ exposing (Proto__Com__Book__Book)
-- import Proto.Com.Book.EnumSample exposing (..)
import Protobuf.Types.Int64 exposing (fromInts)
import Test exposing (..)

import Json.Decode as JD
import Json.Encode as JE

-- TODO: uncomment when tests runner bug gets fixed!
-- expectedFoo : Proto__Foo__Foo
-- expectedFoo = Proto__Foo__Foo "" [] (Just (Proto__Google__Protobuf__Timestamp (fromInts 0 1) 0)) (Just (Proto__Com__Book__Book (fromInts 0 1) "someTitle" "someAuthor"))

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
                                                  }""" |> Expect.equal (Ok (Proto__Foo__Foo "" [] (Just (Proto__Google__Protobuf__Timestamp (fromInts 0 947203200) 0)) (Just (Proto__Com__Book__Book (fromInts 0 0) "someTitle" "someAuthor"))))
        ]
