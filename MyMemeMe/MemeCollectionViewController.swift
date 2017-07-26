//
//  MemeCollectionViewController.swift
//  MyMemeMe
//
//  Created by Edwin de Jongh on 23/07/2017.
//  Copyright © 2017 Dev66. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeCell"

class MemeCollectionViewController: UICollectionViewController {

    // MARK: outlet
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: properties
    
    var memes: [Meme]!

    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        
        // call super
        super.viewDidLoad()
        
        // determine available space
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        // set dimensions
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // reload table data
    override func viewDidAppear(_ animated: Bool) {
        
        // call super
        super.viewDidAppear(animated)
        
        // reload table data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        self.collectionView?.reloadData()
    }

    // MARK: UICollectionViewDataSource

    // number of items to display
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        print("count=\(memes.count)")
        return memes.count
    }

    // display cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get references
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        // set meme image for cell
        cell.imageView?.image = meme.memedImage
        
        // done
        return cell
    }

    // row selected
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // show detail view controller
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailController") as! MemeDetailController
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }

    // show meme editor
    @IBAction func showMemeEditor(_ sender: Any) {
        
        let memeEditor = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        present(memeEditor, animated: true, completion: nil)
        
    }
}
