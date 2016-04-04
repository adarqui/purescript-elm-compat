
-- | Library for [bitwise operations](http://en.wikipedia.org/wiki/Bitwise_operation)
-- |
-- | Implemented using Purescript's [`Data.Int.Bits`](https://pursuit.purescript.org/packages/purescript-integers) module.

module Elm.Bitwise
    ( module Virtual
    , and, or, xor, shiftLeft, shiftRight, shiftRightLogical
    ) where


-- For re-export

import Data.Int.Bits (complement) as Virtual

-- Internal

import Data.Int.Bits ((.&.), (.|.), (.^.), shl, shr, zshr)


-- | Bitwise AND
-- |
-- | Equivalent to Purescript's `(.&.)`
and :: Int -> Int -> Int
and = (.&.)


-- | Bitwise OR
-- |
-- | Equivalent to Purescript's `(.|.)`
or :: Int -> Int -> Int
or = (.|.)


-- | Bitwise XOR
-- |
-- | Equivalent to Purescript's `(.^.)`
xor :: Int -> Int -> Int
xor = (.^.)


-- | Shift bits to the left by a given offset, filling new bits with zeros.
-- | This can be used to multiply numbers by powers of two.
-- |
-- |     8 `shiftLeft` 1 == 16
-- |     8 `shiftLeft` 2 == 32
-- |
-- | Equivalent to Purescript's `shl`
shiftLeft :: Int -> Int -> Int
shiftLeft = shl


-- | Shift bits to the right by a given offset, filling new bits with
-- | whatever is the topmost bit. This can be used to divide numbers by powers of two.
-- |
-- |      32 `shiftRight` 1 == 16
-- |      32 `shiftRight` 2 == 8
-- |     -32 `shiftRight` 1 == -16
-- |
-- | This is called an
-- | [arithmetic right shift](http://en.wikipedia.org/wiki/Bitwise_operation#Arithmetic_shift),
-- | often written (>>), and sometimes called a sign-propagating
-- | right shift because it fills empty spots with copies of the highest bit.
-- |
-- | Equivalent to Purescript's `shr`
shiftRight :: Int -> Int -> Int
shiftRight = shr


-- | Shift bits to the right by a given offset, filling new bits with
-- | zeros.
-- |
-- |      32 `shiftRightLogical` 1 == 16
-- |      32 `shiftRightLogical` 2 == 8
-- |     -32 `shiftRightLogical` 1 == 2147483632
-- |
-- | This is called an
-- | [logical right shift](http://en.wikipedia.org/wiki/Bitwise_operation#Logical_shift),
-- | often written (>>>), and sometimes called a zero-fill right shift because
-- | it fills empty spots with zeros.
-- |
-- | Equivalent to Purescript's `zshr`
shiftRightLogical :: Int -> Int -> Int
shiftRightLogical = zshr

