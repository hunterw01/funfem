---------------------------------------------------------------------------------- 
-- |
-- Module : Solver
-- Copyright : (c) Adrien Haxaire 2011
-- Licence : BSD3
--
-- Maintainer : Adrien Haxaire <adrien@funfem.org>
-- Stability : experimental
-- Portabilty : not tested
--
----------------------------------------------------------------------------------
--

module Numeric.Funfem.Solver (cg) where

import Numeric.Funfem.Vector
import Numeric.Funfem.Matrix


eps :: Double
eps = 1.0e-3

-- | Solves Ax = b. Arguments are passed in this order. No first guess on x is made, so 
-- it should be initialized first.
cg :: Matrix -> Vector -> Vector -> Vector
cg a x b = if norm r <= eps then x else cg' a x r r r
  where
    r = b - multMV a x

cg' :: Matrix -> Vector -> Vector -> Vector -> Vector -> Vector
cg' a x r z p = if norm r' <= eps then x' else cg' a x' r' z' p'
  where
    alpha = (r .* z) / (p .* (multMV a p))
    beta = (z' .* r') / (z .* r)
    x' = x + vmap (*alpha) p
    r' = r - vmap (*alpha) (multMV a p)
    z' = r'    
    p' = z'+ vmap (*beta) p

