{-# LANGUAGE ForeignFunctionInterface #-}

-- |
-- Module : Graphics.Formats.Assimp.Anim
-- Copyright : (c) Joel Burget 2011
-- License BSD3
--
-- Maintainer : Joel Burget <joelburget@gmail.com>
-- Stability : experimental
-- Portability : non-portable
--
-- Corresponds to aiAnim.h

module Graphics.Formats.Assimp.Anim (
    NodeAnim(..)
  , MeshAnim(..)
  , Animation(..)
  ) where

#include "aiAnim.h"
#include "typedefs.h"
#let alignment t = "%lu", (unsigned long)offsetof(struct {char x__; t (y__); }, y__)

import Control.Monad (liftM)
import Foreign.Storable
import Foreign.Marshal.Array (peekArray)
import Graphics.Formats.Assimp.Types

data NodeAnim = NodeAnim 
  { dummy'NodeAnim :: Int
  } deriving (Show)

data MeshAnim = MeshAnim 
  { dummy'MeshAnim :: Int
  } deriving (Show)

data Animation = Animation 
  { animationName  :: String
  , duration       :: Double
  , ticksPerSecond :: Double
  , channels       :: [NodeAnim]
  , meshChannels   :: [MeshAnim]
  } deriving (Show)

instance Name Animation where
  name = animationName

instance Storable NodeAnim where
  sizeOf _ = #size aiNodeAnim
  alignment _ = #alignment aiNodeAnim
  peek _ = return $ NodeAnim 0
  poke = undefined

instance Storable MeshAnim where
  sizeOf _ = #size aiMeshAnim
  alignment _ = #alignment aiMeshAnim
  peek _ = return $ MeshAnim 0
  poke = undefined

instance Storable Animation where
  sizeOf _ = #size aiAnimation
  alignment _ = #alignment aiAnimation
  peek p = do
    mName            <- liftM aiStringToString $ (#peek aiAnimation, mName) p
    mDuration        <- (#peek aiAnimation, mDuration) p
    mTicksPerSecond  <- (#peek aiAnimation, mTicksPerSecond) p
    mNumChannels     <- (#peek aiAnimation, mNumChannels) p
    mChannels'       <- (#peek aiAnimation, mChannels) p
    mChannels        <- peekArray mNumChannels mChannels'
    mNumMeshChannels <- (#peek aiAnimation, mNumMeshChannels) p
    mMeshChannels'   <- (#peek aiAnimation, mMeshChannels) p
    mMeshChannels    <- peekArray mNumMeshChannels mMeshChannels'
    return $ Animation mName mDuration mTicksPerSecond mChannels mMeshChannels
  poke = undefined
