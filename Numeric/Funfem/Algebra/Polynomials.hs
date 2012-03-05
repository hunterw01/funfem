{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
---------------------------------------------------------------------------------- 
-- |
-- Module : Numeric.Funfem.Algebra.Polynomials
-- Copyright : (c) Adrien Haxaire 2012
-- Licence : BSD3
--
-- Maintainer : Adrien Haxaire <adrien@funfem.org>
-- Stability : experimental
-- Portabilty : not tested
-- 
-- Multivariate 'Polynomial's. Defined to represent shape functions, allowing
-- their exact multiplication, addition and integration. 
-- 
-- A barebone Num instance is provided, but the functions 'add', 'substract'
-- and 'mult' are provided for comodity.

module Numeric.Funfem.Algebra.Polynomials (
                                           Polynomial
                                           ,Eval
                                           ,differentiate
                                           ,integrate
                                           ,eval
                                           ,add
                                           ,substract
                                           ,mult
                                          ) where

import qualified Data.Map as M
import Data.List (delete) 
import Data.Maybe

-- | Representation of a multivariate polynomial.
type Polynomial = M.Map String Double

-- | Type alias to evaluate a 'Polynomial'. See the 'eval' function for an example of usage.
type Eval = M.Map Char Double


-- count the occurences of a monomial in a term
occ :: Char -> String -> Double 
occ _ [] = 0.0
occ c (x:xs) = let n = if c == x then 1.0 else 0.0 in n + occ c xs


-- | The 'differentiate' function calculates the derivative of a 'Polynomial' with respect to a given variable.
--
-- > let p = M.fromList [("",1.0), ("x",2.0), ("y",3.0), ("xy",4.0), ("xxy",5.0)] :: Polynomial
-- > differentiate p 'x' == M.fromList [("",2.0),("xy",10.0),("y",4.0)]
-- > differentiate p 'y' == M.fromList [("",3.0),("x",4.0),("xx",5.0)]
differentiate :: Polynomial -> Char -> Polynomial
differentiate p c = M.mapKeys (delete c) $
                    M.mapWithKey (\ k v -> (occ c k) * v) $
                    M.filterWithKey (\ k _ -> c `elem` k) p


-- | The 'integrate' function calculates the integral of a 'Polynomial' with respect to a given variable.
--
-- > let p = M.fromList [("",1.0), ("x",2.0), ("y",3.0), ("xy",4.0)] :: Polynomial
-- > integrate p 'x' == M.fromList [("x",1.0),("xx",1.0),("xxy",2.0),("xy",3.0)]
-- > integrate p 'y' == M.fromList [("y",1.0),("yx",2.0),("yxy",2.0),("yy",1.5)]
integrate :: Polynomial -> Char -> Polynomial
integrate p c = M.mapKeys (c:) $ M.mapWithKey (\ k v -> v / (occ c k + 1.0)) p


-- | The 'eval' function evaluates a 'Polynomial' at a point defined through the 'Eval' type alias:
--
-- > let p = M.fromList [("",1.0), ("x",2.0), ("y",3.0), ("xy",4.0), ("xxy",5.0)] :: Polynomial
-- > let e = M.fromList [('x',2.0), ('y',1.0)] :: Eval
-- > eval p e == 36.0
eval :: Polynomial -> Eval -> Double
eval p e = M.foldl (+) 0.0 $ evals p e

evals :: Polynomial -> Eval -> Polynomial
evals p e = evals' p e $ M.keys e
    where
      evals' q _ [] = q
      evals' q ev (c:cs) = evals' (evalOne q ev c) ev cs                 

evalOne :: Polynomial -> Eval -> Char -> Polynomial
evalOne p e c = M.mapWithKey f p
    where
      f k v = v * (x ** (occ c k))
      x = fromJust $ M.lookup c e

instance Num Polynomial where
    p + q = add p q
    p * q = mult p q
    negate = M.map negate
    signum = M.map signum 
    fromInteger = undefined         
    abs = M.map abs

-- | Addition of two 'Polynomial's.
add :: Polynomial -> Polynomial -> Polynomial
add p q = M.unionWith (+) p q

-- | Substraction of two 'Polynomial's.
substract :: Polynomial -> Polynomial -> Polynomial
substract p q = M.unionWith (-) p q

-- | Multiplication of two 'Polynomial's.
mult :: Polynomial -> Polynomial -> Polynomial
mult p q = mult' p q $ M.keys p
    where
      mult' _ _ [] = M.fromList []
      mult' p' q' (key:keys) = add (M.map (* (p' M.! key)) $ M.mapKeys (key ++) q') (mult' p' q' keys)

