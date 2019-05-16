//
//  WordSearchViewController.swift
//  Shopify Challenge F19
//
//  Created by MICHAEL on 2019-05-01.
//  Copyright © 2019 Michael Truong. All rights reserved.
//

import UIKit

protocol WordSearchCollectionViewControllerDelegate: class {
    func getWordsList(_ words: [Word])
}

final class WordSearchViewController: UICollectionViewController {

    // MARK: - Properties
    private let reuseIdentifier = "WordSearchCell"
    private var currentIndexPath: IndexPath?
    
    var words = [Word("OBJECTIVEC"), Word("SWIFT"),
                 Word("JAVA"), Word("KOTLIN"),
                 Word("MOBILE"), Word("VARIABLE")]
    
    var selectedWord: String = ""
    var selectedCellsCoord = [(Int,Int)]()
    var beginCellCoord: (Int, Int) = (0,0)
    var endCellCoord: (Int, Int) = (0,0)
    
    lazy var wordGrid = WordGrid(of: 10, using: self.words)
    
    private var shopifyGreen = UIColor(red: 149/255, green: 190/255, blue: 71/255, alpha: 0.9)
    
    weak var delegate: WordSearchCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Shadow
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOpacity = 0.2
        self.view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.view.layer.shadowRadius = 15.0
        
        delegate?.getWordsList(wordGrid.words)
    }

    
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: view)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            let row = indexPath.section
            let col = indexPath.item
            if sender.state == .began {
                // Restores default states
                beginCellCoord = (row,col)
                endCellCoord = (row,col)
                selectedWord = ""
                selectedCellsCoord.removeAll()
            } else if sender.state == .changed {
                if endCellCoord != (row,col) {
                    endCellCoord = (row, col)
                    updateGridColor(at: selectedCellsCoord, to: .white)
                    selectedCellsCoord = getLine(from: beginCellCoord, to: endCellCoord)
                    updateGridColor(at: selectedCellsCoord, to: shopifyGreen)
                }
            } else if sender.state == .ended {
                // TODO: Check if the currend line is a word
                updateGridColor(at: selectedCellsCoord, to: .white)
                selectedCellsCoord = getLine(from: beginCellCoord, to: endCellCoord)
                if wordGrid.checkWord(Word(selectedWord), at: selectedCellsCoord) {
                    updateGridColor(at: selectedCellsCoord, to: shopifyGreen )
                    print("HERE")
                    delegate?.getWordsList(wordGrid.words)
                }
            }
        }
    }
    
    func updateGridColor(at line: [(Int,Int)], to color: UIColor) {
        
        for coord in line {
            let row = coord.0
            let col = coord.1
            if let cell = collectionView.cellForItem(at: IndexPath(item: coord.1, section: coord.0)) {
                print(wordGrid.grid[row][col].status)
                if color != shopifyGreen {
                    // Clearing the colour
                    if !wordGrid.grid[row][col].status {
                        cell.backgroundColor = color
                    }
                } else {
                    cell.backgroundColor = color
                }
            }
        }
    }
    
    ///
    // (row, col) or (section,item)
    func getLine(from begin: (Int, Int), to end: (Int, Int)) -> [(Int,Int)] {
        var line = [(Int,Int)]()
        
        let rowDiff = end.0 - begin.0
        let colDiff = end.1 - begin.1
        var absoluteDiff = 0
        
        // Look-up table to find the corresponding increment to draw the line
        var increment = (0,0)
        if rowDiff == 0 && colDiff > 0 {
            increment = wordGrid.directionIncrement[.leftRight]!
        } else if rowDiff == 0 && colDiff < 0 {
            increment = wordGrid.directionIncrement[.rightLeft]!
        } else if rowDiff > 0 && colDiff == 0 {
            increment = wordGrid.directionIncrement[.topDown]!
        } else if rowDiff > 0 && colDiff > 0 {
            increment = wordGrid.directionIncrement[.topDownDiagonalRight]!
            absoluteDiff = abs(rowDiff) - abs(colDiff)
        } else if rowDiff > 0 && colDiff < 0 {
            increment = wordGrid.directionIncrement[.topDownDiagonalLeft]!
            absoluteDiff = abs(rowDiff) - abs(colDiff)
        } else if rowDiff < 0 && colDiff == 0 {
            increment = wordGrid.directionIncrement[.bottomUp]!
        } else if rowDiff < 0 && colDiff > 0 {
            increment = wordGrid.directionIncrement[.bottomUpDiagonalRight]!
            absoluteDiff = abs(rowDiff) - abs(colDiff)
        } else if rowDiff < 0 && colDiff < 0 {
            increment = wordGrid.directionIncrement[.bottomUpDiagonalLeft]!
            absoluteDiff = abs(rowDiff) - abs(colDiff)
        }
        
        // Validates the direction of the line -- otherwise returning an empty line
        guard absoluteDiff == 0 else { return line }
        
        // Updates the cells which corresponds to the valid direction to create the highlighted line
        var current = begin
        selectedWord = ""
        while (current != (end.0 + increment.0, end.1 + increment.1)) {
            if let _ = collectionView.cellForItem(at: IndexPath(row: current.1, section: current.0)) {
                selectedWord = selectedWord + "\(wordGrid.grid[current.0][current.1].letter)"
                line.append(current)
            }
            
            current.0 += increment.0
            current.1 += increment.1
        }
        
        return line
    }
    
    // MARK: UICollectionViewDelegate
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
//        print("Hightlight")
//        beginCellCoord = (indexPath.section,indexPath.item)
//        endCellCoord = beginCellCoord
//        getLine(from: beginCellCoord, to: endCellCoord)
        return true
    }

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }*/
}

// MARK: - UICollectionViewDataSource
extension WordSearchViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return wordGrid.size
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordGrid.size
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WordSearchCell
        
        // Configure the cell
        let row = indexPath.section
        let col = indexPath.item
        cell.letterLabel.text = "\(wordGrid.grid[row][col].letter)"
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WordSearchViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(wordGrid.size)
        let widthPerItem = view.frame.width / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
