import Foundation

infix operator ** { associativity left precedence 170 }

func ** (num: Double, power: Double) -> Double{
    return pow(num, power)
}

var x:Double = 2
x**2

var list = [1,2,3,4]
find(list, 0)

