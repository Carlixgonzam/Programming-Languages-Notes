{-# LANGUAGE RankNTypes #-}

pair :: (Int, Bool)
pair = let ident = \x -> x
       in (ident 3, ident True)

class MyEq a where
  eq :: a -> a -> Bool

instance MyEq Int where
  eq x y = x == y

instance MyEq Bool where
  eq True  True  = True
  eq False False = True
  eq _     _     = False

allEqual :: MyEq a => [a] -> Bool
allEqual xs = and (zipWith eq xs (drop 1 xs))

apply2 :: (forall a. a -> a) -> (Int, Bool)
apply2 f = (f 3, f True)

main :: IO ()
main
  | pair == (3, True)
    && allEqual [1, 1, 1 :: Int] && not (allEqual [True, False])
    && apply2 id == (3, True) = putStrLn "ok"
  | otherwise = error "FAIL"
