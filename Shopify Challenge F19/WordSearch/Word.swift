//
//  Word.swift
//  Shopify Challenge F19
//
//  Created by MICHAEL on 2019-05-01.
//  Copyright © 2019 Michael Truong. All rights reserved.
//

import Foundation

//enum LetterStatus: Int {
//    case available
//    case unavailable
//    case found
//}

struct Letter: CustomStringConvertible {
    var letter: Character
    var status: Bool
    
    var description: String {
        return "(\(letter),\(status))"
    }
}

enum WordDirection: Int {
    case leftRight
    case rightLeft
    case topDown
    case topDownDiagonalRight
    case topDownDiagonalLeft
    case bottomUp
    case bottomUpDiagonalRight
    case bottomUpDiagonalLeft
}

class Word {
    let direction: WordDirection
    let word: String
    var length: Int {
        return word.count
    }
    var isFound: Bool
    
    init(_ word: String, with direction: WordDirection) {
        self.word = word
        self.direction = direction
        self.isFound = false
    }
    
    init(_ word: String) {
        var rawValue = Int(arc4random_uniform(7))
        if (rawValue > 7 || rawValue < 0) { rawValue = 0 }
        self.direction = WordDirection(rawValue: rawValue)!
        self.word = word
        self.isFound = false
    }
}

extension Word: CustomStringConvertible {
    var description: String {
        return "(\(self.word), \(self.direction), \(self.isFound))"
    }
}

extension Word: Comparable {
    static func < (lhs: Word, rhs: Word) -> Bool {
        return lhs.word.count < rhs.word.count
    }
    
    static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.word.count == rhs.word.count
    }
}
