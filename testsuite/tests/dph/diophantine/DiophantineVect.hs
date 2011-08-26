{-# LANGUAGE ParallelArrays #-}
{-# OPTIONS -fvectorise -XParallelListComp #-}
module DiophantineVect (solution3) where

import Data.Array.Parallel
import Data.Array.Parallel.Prelude.Int

import qualified Prelude as P

solution3'
 = let
     pow x i     = productP (replicateP i x)
     primes      = [: 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73 :]
     a `cutTo` b = sliceP 0 (lengthP b) a
     sumpri xx   = productP [: pow p x | p <- primes `cutTo` xx | x <- xx :]
     distinct xx = productP [: x + 1   | x <- xx :]
     
     series :: [:Int:] -> Int -> [:[:Int:]:]
     series xs n     
       | n == 1      = [: [: 0 :] :]
       | otherwise   = [: [: x :] +:+ ps 
                             | x <- xs
                             , ps <- series (enumFromToP 0 x) (n-1) :]
     
     prob x y        
      = let  xx      = [: (sumpri m ,m) 
                             | m <- series (enumFromToP 1 3) x
                             , distinct [: x * 2 | x <- m :] > y :]          
             i       = minIndexP [: a | (a, b) <- xx :]
        in   xx !: i 
   in
   prob 5 200

solution3 :: (Int, PArray Int)
{-# NOINLINE solution3 #-}
solution3
  = let (i, is) = solution3'
    in
    (i, toPArrayP is)
