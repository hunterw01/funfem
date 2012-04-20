---------------------------------------------------------------------------------- 
-- |
-- Module : LU
-- Copyright : (c) Adrien Haxaire 2012
-- Licence : BSD3
--
-- Maintainer : Adrien Haxaire <adrien@funfem.org>
-- Stability : experimental
-- Portabilty : not tested
--
----------------------------------------------------------------------------------
--

module Numeric.Funfem.Algebra.Solver.LU where

import Numeric.Funfem.Algebra.Tensor as T

type Matrix = Tensor Double

{-
-- | Solves Ax=b using LU decomposition and backsubstitution
lu :: M.Matrix -> V.Vector -> V.Vector
lu a b = findX upper V.empty $ findY lower V.empty b 
  where
    (lower, upper) = luFact a

-- solve Ly = b
findY :: M.Matrix -> V.Vector -> V.Vector -> V.Vector
findY ls ys bs = if V.null ls then ys else findY (V.tail ls) (ys V.++ vector [y]) bs
  where
    y = b - dotProd (V.init l) ys
    b = bs V.! V.length ys
    l = V.head ls

-- solve Ux = y
findX :: M.Matrix -> V.Vector -> V.Vector -> V.Vector
findX us xs ys = if V.null us then xs else findX (V.init us) (V.cons x xs) ys
  where 
    u = V.last us 
    y = V.drop (V.length us - 1) ys
    x = (V.head y - dotProd (V.tail u) xs) / V.head u

luFact :: M.Matrix -> (M.Matrix, M.Matrix)
luFact m | V.length m < 2 = (V.empty, V.empty)
         | otherwise = (reorder lower V.empty, upper)
  where
    (lower, upper) = luFact' (V.empty, V.empty) m

luFact' :: (M.Matrix, M.Matrix) -> M.Matrix -> (M.Matrix, M.Matrix)
luFact' (lower, upper) m | V.null m        = (V.empty, V.empty) 
                         | V.length m == 1 = (lower V.++ matrix [[1.0]], upper V.++ matrix [[u11]])
                         | otherwise       = luFact' (lower V.++ l, upper V.++ u) minorLU
  where
    minorLU = V.zipWith (-) (minor m) (vecProd matL21 matU12)
    u11 = V.head $ V.head m
    matU12 = V.tail $ V.head m
    matL21 = V.map (/ u11) $ V.tail (M.column 1 m)
    u = V.cons (V.cons u11 matU12) V.empty
    l = V.fromList [V.vector [1.0] V.++ matL21]

reorder :: M.Matrix -> M.Matrix -> M.Matrix
reorder ls rs = if V.length ls == 1 then V.cons r rs else reorder ls' (V.cons r rs)
  where
    r = V.map V.last ls
    ls' = V.init $ V.map V.init ls

-}