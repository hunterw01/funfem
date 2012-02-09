---------------------------------------------------------------------------------- 
-- |
-- Module : CG
-- Copyright : (c) Adrien Haxaire 2012
-- Licence : BSD3
--
-- Maintainer : Adrien Haxaire <adrien@funfem.org>
-- Stability : experimental
-- Portabilty : not tested
--
----------------------------------------------------------------------------------
--

module Numeric.Funfem.Algebra.Solver.CG (
  cg
  ) where


import qualified Data.Vector as V

import Numeric.Funfem.Algebra.Vector
import Numeric.Funfem.Algebra.Matrix

-- | Solves Ax = b using the conjugate gradient method. Not
-- preconditionned and unstable; the LU solver should be prefered.
cg :: Matrix -> Vector -> Vector
cg a b = cg' a x0 b b b
  where
    x0 = V.replicate (V.length a) 0.0
    
cg' :: Matrix -> Vector -> Vector -> Vector -> Vector -> Vector
cg' a x r z p = if norm r' <= eps then x' else cg' a x' r' z' p'
  where
    alpha = (r .* z) / (p .* multMV a p)
    beta = (z' .* r') / (z .* r)
    x' = x + V.map (*alpha) p
    r' = r - V.map (*alpha) (multMV a p)
    z' = r' -- placeholder for preconditioner  
    p' = z'+ V.map (*beta) p
    eps = 1.0e-3
