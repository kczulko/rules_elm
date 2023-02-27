module Spec exposing(..)

import Expect
import Test exposing (..)
import Lib exposing(plus2)

additionTests =
    describe "Addition"
        [ test "two plus two equals four" <|
            \_ -> (2 + 2) |> Expect.equal 4
        , test "three plus four equals seven" <|
            \_ -> (3 + 4) |> Expect.equal 7
        , test "plus2 adds two to the argument" <|
            \_ -> plus2 2 |> Expect.equal 4
        ]

