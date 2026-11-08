import Data.List (foldl')

three :: Integer -> Integer
three x = 3

infinity :: Integer
infinity = infinity + 1

from :: Int -> [Int]
from n = n : from (n + 1)

isPrime :: Int -> Bool
isPrime n = n > 1 && all (\d -> n `mod` d /= 0) (takeWhile (\d -> d * d <= n) [2 ..])

firstPrime :: [Int] -> Int
firstPrime [] = 0
firstPrime (x:xs) = if isPrime x then x else firstPrime xs

ones :: [Int]
ones = 1 : ones

fibs :: [Integer]
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)

main :: IO ()
main
  | three infinity == 3
    && take 5 (from 1) == [1, 2, 3, 4, 5]
    && firstPrime (from 90) == 97
    && take 3 ones == [1, 1, 1]
    && take 10 fibs == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
    && foldl' (+) 0 [1 .. 1000000 :: Int] == 500000500000 = putStrLn "ok"
  | otherwise = error "FAIL"
