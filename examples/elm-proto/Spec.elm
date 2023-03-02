module Spec exposing (..)

import Expect
import Book exposing (..)
import Test exposing (..)

import Json.Decode as JD
import Json.Encode as JE

decodersTest =
    describe "Decoders usage"
        [ test "EnumSample" <|
            \_  -> JD.decodeString (JD.list enumSampleDecoder) """["UNKNOWN"]""" |> Expect.equal (Ok [Unknown])
        , test "Book" <|
            \_  -> JD.decodeString bookDecoder """{
                                                    "isbn": 1,
                                                    "title": "someTitle",
                                                    "author": "someAuthor"
                                                  }""" |> Expect.equal (Ok (Book 1 "someTitle" "someAuthor"))
        ]
