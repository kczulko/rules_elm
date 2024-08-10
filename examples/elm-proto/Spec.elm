module Spec exposing (..)

import Expect
import Proto.Com.Book exposing (..)
import Proto.Com.Book.Internals_ exposing (Proto__Com__Book__Book)
import Proto.Com.Book.EnumSample exposing (..)
import Protobuf.Types.Int64 exposing (fromInts)
import Test exposing (..)

import Json.Decode as JD
import Json.Encode as JE

someOtherNotUselessFunctionWhichIsNotATest = "dummy string"

decodersTest =
    describe "Decoders usage"
        [ test "EnumSample" <|
            \_  -> JD.decodeString (JD.list jsonDecodeEnumSample) """["UNKNOWN"]""" |> Expect.equal (Ok [UNKNOWN])
        , test "Book" <|
            \_  -> JD.decodeString jsonDecodeBook """{
                                                    "isbn": 1,
                                                    "title": "someTitle",
                                                    "author": "someAuthor"
                                                  }""" |> Expect.equal (Ok (Proto__Com__Book__Book (fromInts 0 1) "someTitle" "someAuthor"))
        ]
