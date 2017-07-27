//
//  MemeCollectionViewCell.swift
//  MyMemeMe
//
//  Created by Edwin de Jongh on 23/07/2017.
//  Copyright © 2017 Dev66. All rights reserved.
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
   
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var bottomText: UILabel!
    
    // setup labels and image based on the meme from the parameter
    func setupCellWith(meme:Meme) {
    
        self.imageView.image = meme.originalImage
        self.topText.text = meme.topText
        self.bottomText.text = meme.bottomText
        
    }
    
   
}
