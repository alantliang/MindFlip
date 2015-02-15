// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

3 % 2

-10 % 2

func mod(x: Int, m: Int) -> Int {
    var r = x % m
    return r < 0 ? r + m : r
}

mod(-1, 2)
