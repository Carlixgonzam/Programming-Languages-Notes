data List a = Nil | Cons a (List a)

data Tree a = Leaf a | Node (Tree a) a (Tree a)

len :: List a -> Int
len Nil         = 0
len (Cons _ xs) = 1 + len xs

size :: Tree a -> Int
size (Leaf _)     = 1
size (Node l _ r) = size l + 1 + size r

main :: IO ()
main
  | len (Cons 'a' (Cons 'b' Nil)) == 2
    && size (Node (Leaf 1) 2 (Node (Leaf 3) 4 (Leaf (5 :: Int)))) == 5 = putStrLn "ok"
  | otherwise = error "FAIL"
