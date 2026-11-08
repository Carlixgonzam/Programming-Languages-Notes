-- <<double>>
doubleSmallNumber x = if x > 100
                        then x
                        else x * 2
-- <<double.end>>

main :: IO ()
main
  | doubleSmallNumber 50 == 100 && doubleSmallNumber 150 == 150 = putStrLn "ok"
  | otherwise = error "FAIL"
