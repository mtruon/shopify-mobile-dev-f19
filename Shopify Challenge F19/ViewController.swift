//
//  ViewController.swift
//  Shopify Challenge F19
//
//  Created by MICHAEL on 2019-05-02.
//  Copyright © 2019 Michael Truong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var foundLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "wordSearch") {
            let wordSearchViewController = segue.destination as! WordSearchViewController
            wordSearchViewController.delegate = self
        }
    }

}

extension ViewController: WordSearchCollectionViewControllerDelegate {
    func getWordsList(_ words: [Word]) {
        var found = 0
        for word in words {
            if word.isFound {
                found += 1
            }
        }
        foundLabel.text = "\(found)/\(words.count)"
        
    }
}
