
-- | A library for manipulating lists of values. Every value in a
-- | list must have the same type.
-- |
-- | Implemented in terms of Purescript's `Data.List`, so you can also
-- | use functions from `Data.List` on a `List`.
-- |
-- | Note that Purescript uses `:` for `cons` and and `::` to indicate the type
-- | of a thing, which is exactly the opposite of Elm.
-- |
-- | Purescript's compiler doesn't have a literal
-- | syntax for lists, so instead of this:
-- |
-- |     [1, 2, 3]
-- |
-- | ... you need to do something like this:
-- |
-- |     (1 : 2 : 3 : Nil)
-- |
-- | There is a literal syntax for `Array`, e.g. `[1, 2, 3]`. However, the `Array` type in Purescript
-- | is actually a Javascript array, which is typically not what you want (unless you're getting
-- | one from elsewhere anyway). And, it's not what `Elm.Array` is.
-- |
-- | What you can do, though, to get a list is something like this:
-- |
-- |     Data.List.toList [1, 2, 3]
-- |
-- | ... which is a nice little trick when porting code, as all you have to add is the `Data.List.toList`.
-- |
-- | I have also made some of the Elm APIs accept either `Elm.List`, `Array` or `Elm.Array` by using
-- | type-classes in the function signatures.

module Elm.List
    ( module Virtual
    , cons, (:), isEmpty, member
    , map2, map3, map4, map5
    , intersperse, scanl
    , indexedMap, filterMap, partition, unzip
    , repeat, sortBy, sortWith
    , range, (..)
    ) where


-- For re-export

import Data.List
    ( List(..), head, tail, filter, length, reverse
    , concat, concatMap, take, drop, sort
    ) as Virtual

import Data.Foldable
    ( foldr, all, any, sum, product, maximum, minimum
    ) as Virtual

import Elm.Foldable (foldl) as Virtual

import Prelude (map, append) as Virtual


-- Internal

import Data.List
    ( List(..), elemIndex, length
    , toList, fromList, zipWith, mapMaybe, replicate
    )

import Data.List.ZipList (ZipList(..), runZipList)
import Elm.Maybe (Maybe(..))
import Data.Foldable (foldr)
import Data.Tuple (Tuple(..))
import Data.Function (on)
import Control.Apply (lift3, lift4, lift5)
import Prelude (class Eq, class Ord, (-), ($), compare, flip, (>))
import Elm.Basics (Order, Bool)


infixr 5 cons as :

-- | Add an element to the front of a list.
-- |
-- |     cons 1 (2 : 3 : Nil] == (1 : 2 : 3 : Nil)
-- |     cons 1 Nil == (1 : Nil)
cons :: ∀ a. a -> List a -> List a
cons = Data.List.Cons


-- | Determine if a list is empty.
-- |
-- |     isEmpty Nil == True
-- |
-- | Equivalent to Purescript's `null`.
isEmpty :: ∀ a. List a -> Bool
isEmpty = Data.List.null


-- | Figure out whether a list contains a value.
-- |
-- |     member 9 (1 : 2 : 3 : 4 : Nil) == False
-- |     member 4 (1 : 2 : 3 : 4 : Nil) == True
member :: ∀ a. (Eq a) => a -> List a -> Bool
member x xs =
    case elemIndex x xs of
         Just _ -> true
         Nothing -> false


-- | Same as `map` but the function is also applied to the index of each
-- | element (starting at zero).
-- |
-- |     indexedMap Tuple ("Tom" : "Sue" : "Bob" : Nil) == (Tuple 0 "Tom" : Tuple 1 "Sue" : Tuple 2 "Bob" : Nil)
indexedMap :: ∀ a b. (Int -> a -> b) -> List a -> List b
indexedMap func list =
    zipWith func r list
        where
            r =
                range 0 (length list - 1)


-- | Reduce a list from the left, building up all of the intermediate results into a list.
-- |
-- |     scanl (+) 0 (1 : 2 : 3 : 4 : Nil) == (0 : 1 : 3 : 6 : 10 : Nil)
-- |
-- | This is like Purescript's `scanl`, except that the function you provide in the first
-- | parameter is flipped, and the second parameter is included in the resulting list.
scanl :: ∀ a b. (a -> b -> b) -> b -> List a -> List b
scanl func memo list =
    memo : Data.Traversable.scanl (flip func) memo list


-- | Apply a function that may succeed to all values in the list, but only keep
-- | the successes.
-- |
-- |     filterMap isTeen [3, 15, 12, 18, 24] == [15, 18]
-- |
-- |     isTeen :: Int -> Maybe Int
-- |     isTeen n =
-- |         if 13 <= n && n <= 19
-- |             then Just n
-- |             else Nothing
-- |
-- | Equivalent to Purescript's `mapMaybe`.
filterMap :: ∀ a b. (a -> Maybe b) -> List a -> List b
filterMap = mapMaybe


-- | Partition a list based on a predicate. The first list contains all values
-- | that satisfy the predicate, and the second list contains all the value that do
-- | not.
-- |
-- |     partition (\x -> x < 3) (0..5) == {trues: (0 : 1 : 2 : Nil), falses: (3 : 4 : 5 : Nil)}
-- |     partition isEven        (0..5) == {trues: (0 : 2 : 4 : Nil), falses: (1 : 3 : 5 : Nil)}
-- |
-- | Note that the result is a record of `{trues, falses}`, whereas in Elm the result
-- | was a `Tuple`.
partition :: ∀ a. (a -> Bool) -> List a -> { trues :: List a, falses :: List a }
partition pred list =
    foldr step { trues: Nil, falses: Nil } list
        where
            step x memo =
                if pred x
                    then memo { trues = x : memo.trues }
                    else memo { falses = x : memo.falses }


-- | Combine two lists, combining them with the given function.
-- | If one list is longer, the extra elements are dropped.
-- |
-- |     map2 (+) (1 : 2 : 3 : Nil) (1 : 2 : 3 : 4 : Nil) == (2 : 4 : 6 : Nil)
-- |
-- |     map2 Tuple (1 : 2 : 3 : Nil) ('a' : 'b' : Nil) == (Tuple 1 'a' : Tuple 2 'b' : Nil)
-- |
-- |     pairs :: List a -> List b -> List (Tuple a b)
-- |     pairs lefts rights =
-- |         map2 Tuple lefts rights
-- |
-- | Equivalent to Purescript's `zipWith`.
map2 :: ∀ a b result. (a -> b -> result) -> List a -> List b -> List result
map2 = zipWith


map3 :: ∀ a b c result. (a -> b -> c -> result) -> List a -> List b -> List c -> List result
map3 func list1 list2 list3 =
    toList $ runZipList $ lift3 func (ZipList $ fromList list1) (ZipList $ fromList list2) (ZipList $ fromList list3)


map4 :: ∀ a b c d result. (a -> b -> c -> d -> result) -> List a -> List b -> List c -> List d -> List result
map4 func list1 list2 list3 list4 =
    toList $ runZipList $ lift4 func (ZipList $ fromList list1) (ZipList $ fromList list2) (ZipList $ fromList list3) (ZipList $ fromList list4)


map5 :: ∀ a b c d e result. (a -> b -> c -> d -> e -> result) -> List a -> List b -> List c -> List d -> List e -> List result
map5 func list1 list2 list3 list4 list5 =
    toList $ runZipList $ lift5 func (ZipList $ fromList list1) (ZipList $ fromList list2) (ZipList $ fromList list3) (ZipList $ fromList list4) (ZipList $ fromList list5)


-- | Decompose a list of tuples into a tuple of lists.
-- |
-- |     unzip (Tuple 0 True : Tuple 17 False :  Tuple 1337 True : Nil) == Tuple (0 : 17 : 1337 : Nil) (True : False : True : Nil)
unzip :: ∀ a b. List (Tuple a b) -> Tuple (List a) (List b)
unzip pairs =
    let
        step (Tuple x y) (Tuple xs ys) =
            Tuple (x : xs) (y : ys)

    in
        foldr step (Tuple Nil Nil) pairs


-- | Places the given value between all members of the given list.
-- |
-- |     intersperse "on" ("turtles" : "turtles" : "turtles" : Nil) == ("turtles" : "on" : "turtles" : "on" : "turtles" : Nil)
intersperse :: ∀ a. a -> List a -> List a
intersperse sep xs =
    case xs of
        Nil -> Nil

        Cons hd tl ->
            let
                step x rest =
                    sep : x : rest

                spersed =
                    foldr step Nil tl

            in
                hd : spersed


-- | Create a list with *n* copies of a value:
-- |
-- |     repeat 3 0 == (0 : 0 : 0 : Nil)
-- |
-- | Equivalent to Purescript's `replicate`.
repeat :: ∀ a. Int -> a -> List a
repeat = replicate


-- | Sort values by a derived property.
-- |
-- |     alice = { name: "Alice", height: 1.62 }
-- |     bob   = { name: "Bob"  , height: 1.85 }
-- |     chuck = { name: "Chuck", height: 1.76 }
-- |
-- |     sortBy _.name   (chuck : alice : bob : Nil) == (alice : bob : chuck : Nil)
-- |     sortBy _.height (chuck : alice : bob : Nil) == (alice : chuck : bob : Nil)
-- |
-- |     sortBy String.length ("mouse" : "cat" : Nil) == ("cat" : "mouse" : Nil)
-- |
-- | Note that this is not the same as Purescript's `sortBy`, which is
-- | like Elm's `sortWith`.
sortBy :: ∀ a comparable. (Ord comparable) => (a -> comparable) -> List a -> List a
sortBy func =
    Data.List.sortBy (compare `on` func)


-- | Sort values with a custom comparison function.
-- |
-- |     sortWith flippedComparison (1..5) == (5 : 4 : 3 : 2 : 1 : Nil)
-- |
-- |     flippedComparison a b =
-- |         case compare a b of
-- |           LT -> GT
-- |           EQ -> EQ
-- |           GT -> LT
-- |
-- | This is also the most general sort function, allowing you
-- | to define any other: `sort == sortWith compare`
-- |
-- | Equivalent to Purescript's `sortBy`.
sortWith :: ∀ a. (a -> a -> Order) -> List a -> List a
sortWith = Data.List.sortBy


infixl 4 range as ..

-- | The Elm built-in range operator `(..)`.
-- |
-- | Like Purescript's `range`, except that the Elm version produces an empty list
-- | if the first parameter is greater than the second.
range :: Int -> Int -> List Int
range low high =
    if low > high
        then Nil
        else Data.List.range low high
