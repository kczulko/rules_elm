module Spec exposing(..)

import Expect
import Test exposing (..)
import Lib exposing(plus2)
import Main

additionTests =
    describe "Addition"
        [ test "two plus two equals four" <|
            \_ -> (2 + 2) |> Expect.equal 4
        , test "three plus four equals seven" <|
            \_ -> (3 + 4) |> Expect.equal 7
        , test "plus2 adds two to the argument" <|
            \_ -> plus2 2 |> Expect.equal 4
        , test "This specific Main module function always returns 5" <|
            \_ -> Main.someFunctionAlwaysReturning5 |> Expect.equal 5
        ]

