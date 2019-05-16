//
//  WordGrid.swift
//  Shopify Challenge F19
//
//  Created by MICHAEL on 2019-05-03.
//  Copyright © 2019 Michael Truong. All rights reserved.
//

import Foundation

class WordGrid {
    // MARK: - Properties
    let size: Int
    var words: [Word]
    var grid = [[Letter]]()
    
    // MARK: - Auxiliary variables
    private let alphabet: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
                                      "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
                                      "U", "V", "W", "X", "Y", "Z"]
    let directionIncrement: [WordDirection : (Int, Int)] = [.leftRight : (0, 1),
                                                            .rightLeft : (0, -1),
                                                            .topDown : (1, 0),
                                                            .topDownDiagonalRight : (1,1),
                                                            .topDownDiagonalLeft : (1,-1),
                                                            .bottomUp : (-1, 0),
                                                            .bottomUpDiagonalRight : (-1,1),
                                                            .bottomUpDiagonalLeft : (-1,-1)]
    
    init(of size: Int, using words: [Word]) {
        self.size = size
        self.words = words
        
        // Creates an empty grid with "_" as a placeholder character
        self.grid = Array(repeating: Array(repeating: Letter(letter: Character("_"), status: false), count: size), count: size)
        
        if (!insertWords(words)) {
            // TODO: Try another combination of word directions
        }
        
        // Populates the grid with noise characters
        for row in 0..<size {
            for col in 0..<size {
                if (self.grid[row][col].letter == "_") {
                    self.grid[row][col].letter = generateRandomCharacter()
                }
            }
        }
    }
    
    /// Returns true if the specified word exists in the word grid's list - ignoring direction.
    func checkWord(_ found: Word, at line: [(Int,Int)]) -> Bool {
        guard line.count == found.word.count else { return false }
        
        let currentGrid = self.grid
        var builtWord = ""
        for coord in line {
            self.grid[coord.0][coord.1].status = true
            builtWord = builtWord + "\(self.grid[coord.0][coord.1].letter)"
        }
        
        guard builtWord == found.word else {
            self.grid = currentGrid
            return false
        }
        
        for i in 0..<words.count {
            if words[i].word == found.word {
                words[i].isFound = true
                return true
            }
        }
        
        return false
    }
    
    func setWordToFound() {
        
    }
    
    // MARK: - Initialization functions
    private func insertWords(_ words: [Word]) -> Bool {
        if (words.isEmpty) {
            return true
        } else {
            let currentGrid = self.grid
            var currentWords = words
            let currentWord = currentWords[0]
            var validPoints = getValidInsertionPoints(currentWord)
            currentWords.removeFirst()
            
            while(!validPoints.isEmpty) {
                let i = Int(arc4random_uniform(UInt32(validPoints.count - 1)))
                if (insertWord(currentWord, at: validPoints.remove(at: i))) {
                    if (insertWords(currentWords)) {
                        return true
                    } else {
                        // Restore the word grid due to insertion route failure
                        self.grid = currentGrid
                    }
                }
            }
            
        }
        
        return false
    }
    
    /// Inserts a word into the grid and returns true if successful
    private func insertWord(_ word: Word, at coord: (Int,Int)) -> Bool {
        let originalGrid = self.grid
        guard let increment = directionIncrement[word.direction] else { return false }
        
        var row = coord.0
        var col = coord.1
        for c in word.word {
            if (self.grid[row][col].letter != "_" && self.grid[row][col].letter != c) {
                self.grid = originalGrid
                return false
            } else {
                // Set the corresponding letter
                self.grid[row][col].letter = c
//                self.grid[row][col].status = true
                
                row = (row + increment.0)
                col = (col + increment.1)
            }
            
        }
        return true
    }
    
    /// Returns a collection of valid coordinates for which the
    /// specified word can be inserted into the word grid
    private func getValidInsertionPoints(_ word: Word) -> [(Int, Int)] {
        var validCoordinates = [(Int, Int)]()
        
        if (word.length > size) {
            return validCoordinates
        }
        guard let increment = directionIncrement[word.direction] else { return validCoordinates }
        let addRow = increment.0 * (word.length - 1)
        let addCol = increment.1 * (word.length - 1)
        
        for row in 0..<self.size {
            for col in 0..<self.size {
                let coord = (row+addRow, col+addCol)
                if isValidCoordinate(coord) {
                    validCoordinates.append((row,col))
                }
            }
        }
        
        return validCoordinates
    }
    
    /// Returns true if the coordinate is a valid entry in the word grid
    private func isValidCoordinate(_ coord: (Int, Int)) -> Bool {
        let row = coord.0
        let col = coord.1
        
        if (row < 0 || row >= self.size) { return false }
        if (col < 0 || col >= self.size) { return false }
        
        return true
    }
    
    /// Returns a random character in the alphabet
    private func generateRandomCharacter() -> Character {
        let rand = Int(arc4random_uniform(26))
        return Character(alphabet[rand])
    }
}
