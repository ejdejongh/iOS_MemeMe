//
//  MemeTableViewController.swift
//  MyMemeMe
//
//  Created by Edwin de Jongh on 22/07/2017.
//  Copyright © 2017 Dev66. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController {
    
    
    // MARK: properties
    var memes: [Meme]!
    
    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        
        // call super
        super.viewDidLoad()
    }
    
    // reload table data
    override func viewDidAppear(_ animated: Bool) {
        
        // call super
        super.viewDidAppear(animated)
        
        // reload table data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        self.tableView.reloadData()
    }
    
    // show meme editor
    @IBAction func showMemeEditor(_ sender: Any) {
        
        let memeEditor = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        present(memeEditor, animated: true, completion: nil)

    }
}

// MARK: UITableViewDataSource
extension MemeTableViewController: UITableViewDataSource {

    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        return memes.count
    }
    
    // show row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get references
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell")!
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        // set meme properties
        cell.textLabel?.text = meme.topText + " - " + meme.bottomText
        cell.imageView?.image = meme.memedImage
        
        // done
        return cell
    }
}

// MARK: UITableViewDelegate
extension MemeTableViewController: UITableViewDelegate {

    // row selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // show detail view controller
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailController") as! MemeDetailController
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
}

