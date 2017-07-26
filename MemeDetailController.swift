//
//  MemeTableDetailController.swift
//  MyMemeMe
//
//  Created by Edwin de Jongh on 22/07/2017.
//  Copyright © 2017 Dev66. All rights reserved.
//

import UIKit

class MemeDetailController: UIViewController {
    
    // MARK: properties
    var meme: Meme!
    
    @IBOutlet weak var imageView: UIImageView!

    // MARK: life cycle
    
    override func viewDidLoad() {
        
        // call super
        super.viewDidLoad()
        
        // show image
        self.imageView.image = meme.memedImage
    }
}
