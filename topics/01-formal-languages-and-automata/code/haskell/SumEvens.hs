sumEvens :: [Int] -> Int
sumEvens = sum . filter even

main :: IO ()
main
  | sumEvens [] == 0 && sumEvens [1, 2, 3, 4] == 6 && sumEvens [5, 7] == 0 = putStrLn "ok"
  | otherwise = error "FAIL"
