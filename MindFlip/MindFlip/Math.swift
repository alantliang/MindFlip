//
//  Math.swift
//  MindFlip
//
//  Created by Alan Liang on 2/14/15.
//  Copyright (c) 2015 fsa. All rights reserved.
//

import Foundation

infix operator ** { associativity left precedence 170 }

func ** (num: Double, power: Double) -> Double{
    return pow(num, power)
}

func mod(x: Int, m: Int) -> Int {
    var r = x % m
    return r < 0 ? r + m : r
}