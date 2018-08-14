//
//  Base43.swift
//  base43Demo
//
//  Created by 伟标刘 on 2018/8/13.
//  Copyright © 2018年 伟标刘. All rights reserved.
//

import Foundation
class Base43 {
    static var ALPHABET : [CChar] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ$*+-./:".cString(using: .utf8)!
    
    static var INDEXES : [Int] {
        var arr = [Int]()
        for _ in 0..<128{
            arr.append(-1)
        }
        
        for i in 0..<ALPHABET.count{
            arr[Int(ALPHABET[i])] = i
        }
        return arr
    }
    
    static func encode(input : [UInt8]) -> String {
        guard input.count > 0 else {
            return ""
        }
        
        var input = self.copyOfRange(source: input, form: 0, to: input.count)
        
        
        var zeroCount = 0
        while (zeroCount < input.count && input[zeroCount] == 0) {
            zeroCount += 1
        }
        
        var temp = [UInt8].init(repeating: 0, count: input.count * 2)
        var j = temp.count
        
        var startAt = zeroCount
        
        while startAt < input.count {
            let mod = divmod43(number: &input, startAt: startAt)
            if input[startAt] == 0 {
                startAt += 1
            }
            
            j -= 1
            
            temp[j] = UInt8(ALPHABET[Int(mod)])
            
        }
        
        while j < temp.count && temp[j] == ALPHABET[0] {
            j += 1
        }
        
        zeroCount -= 1
        
        while zeroCount >= 0 {
            zeroCount -= 1
            
            j -= 1
            
            temp[j] = UInt8(ALPHABET[0])
            
        }
        
        let output = copyOfRange(source: temp, form: j, to: temp.count)
        
        
        return String.init(bytes: output, encoding: String.Encoding.ascii)!
    }
    
    static func decode(input : String) throws -> [UInt8] {
        guard input.count > 0 else {
            return [0]
        }
        
        var input43 = [UInt8].init(repeating: 0, count: input.count)
        
        for i in 0 ..< input.count {
            let char = input.cString(using: String.Encoding.ascii)![i]
            var digit43 = -1
            if (Int(char) >= 0 && Int(char) < 128) {
                digit43 = INDEXES[Int(char)]
            }
            if digit43 < 0 {
                throw NSError(domain: "Illegal character \(char) at \(i)", code: 9)
            }
            input43[i] = UInt8(digit43)
        }
        
        var zeroCount = 0
        while zeroCount < input43.count && input43[zeroCount] == 0 {
            zeroCount += 1
        }
        
        var temp = [UInt8].init(repeating: 0, count: input.count)
        var j = temp.count
        
        var startAt = zeroCount
        
        while startAt < input43.count {
            let mod = divmod256(number43: &input43, startAt: startAt)
            if input43[startAt] == 0 {
                startAt += 1
            }
            j -= 1
            temp[j] = mod
        }
        
        while (j < temp.count && temp[j] == 0){
            j += 1
        }
        
        return self.copyOfRange(source: temp, form: j - zeroCount, to: temp.count);
    }
    
    static func divmod43( number : inout [UInt8] , startAt : Int ) -> UInt8{
        var remainder = 0
        
        for i in startAt ..< number.count {
            let digit256 = Int(number[i]) & 0xff
            let temp = remainder * 256 + digit256
            number[i] = UInt8(temp / 43)
            remainder = temp % 43
        }
        return UInt8(remainder)
    }
    
    static func divmod256( number43 : inout [UInt8] , startAt : Int ) -> UInt8{
        var remainder = 0
        
        for i in startAt ..< number43.count {
            let digit58 = number43[i] & 0xff
            let temp = Int(remainder) * 43 + Int(digit58)
            number43[i] = UInt8(Int(temp) / 256)
            remainder = Int(temp) % 256
        }
        return UInt8(remainder)
    }
    
    
    static func copyOfRange(source : [UInt8] , form : Int , to : Int) -> [UInt8]{
        let arr = NSMutableArray.init(array: source)
        return arr.subarray(with: NSRange.init(location: form, length: to - form)) as! [UInt8]
    }
    
    
}

