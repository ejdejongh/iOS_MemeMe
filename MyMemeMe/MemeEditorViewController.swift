//
//  ViewController.swift
//  MyMemeMe
//
//  Created by Edwin de Jongh on 19/07/2017.
//  Copyright © 2017 Dev66. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: outlets
    
    // handle to relevant UI elements
    @IBOutlet weak var actionsToolbar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var optionsToolbar: UIToolbar!
    @IBOutlet weak var pickButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    // MARK: properties
    
    // create textfield properties dictionary to use
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -1.0]
    
    // MARK: lifecycle
    
    // before the view appears
    override func viewWillAppear(_ animated: Bool) {
        
        // call super
        super.viewWillAppear(animated)
        
        // disable camera button if no camera available
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // disable the share button initially; there is no image to share initially
        shareButton.isEnabled = false
        
        // toolbar button alignment
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        optionsToolbar.items = [space, pickButton, space, cameraButton, space]
        
        // subscribe to keyboard notifications
        subscribeToKeyboardNotifications()
    }

    // before the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        
        // call super
        super.viewWillDisappear(animated)
        
        // unsubscribe from keyboard notifications
        unsubscribeFromKeyboardNotifications()
    }
    
    // on load
    override func viewDidLoad() {
        
        // init meme editable text fields
        configureTextField(textField: self.topTextField, txt: "TOP")
        configureTextField(textField: self.bottomTextField, txt: "BOTTOM")
    }
    
    // MARK: UI configuration
    
    // prevent status bar from overlapping with the top actions toolbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // helper function for setting up a top or bottom meme text field
    func configureTextField(textField: UITextField, txt: String) {
        
        // set initial text, font attributes, alignment, delegate
        textField.text = txt
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self
    }
    
    // toggle toolbars
    func configureBars(hidden:Bool) {
    
        // hide toolbar and navbar
        self.actionsToolbar.isHidden = hidden
        self.optionsToolbar.isHidden = hidden
    }
    
    // MARK: image selection
    
    // open foto selection
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImage(src: .photoLibrary)
    }

    // open camera app
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImage(src: .camera)
    }
    
    // helper function picking an image from lbum or camera
    func pickAnImage(src: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = src
        present(imagePicker, animated: true, completion: nil)
    }
   
    // MARK: keyboard notifications helper functions
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        
        if (self.bottomTextField.isFirstResponder) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    func keyboardWillHide(_ notification:Notification) {
        if (self.bottomTextField.isFirstResponder) {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    // MARK: Meme object saving, sharing
    
    // generate memed image from current screen
    func generateMemedImage() -> UIImage {
        
        // hide toolbar and navbar
        configureBars(hidden: true)
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // show toolbar and navbar
        configureBars(hidden: false)
        
        // done, return result
        return memedImage
    }
    
    // save generated image to Meme struct
    func save() {
        
        // create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())

        // add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }

    // share a generated meme
    @IBAction func shareImage(_ sender: Any) {
        
        // parameter array
        let sharedItems = [generateMemedImage(), "Sharing my Meme!"] as [Any]
        
        // init image share view controller
        let imageSharer = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        
        // set oncomplete handler
        imageSharer.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed == true {
                
                // save meme
                self.save()
                
                // dismiss meme editor
                self.dismiss(animated: true, completion: nil)
                
            }
        }
        
        // show dialog
        present(imageSharer, animated: true, completion: nil)
    }
    
    // MARK: actions
    
    // cancel
    @IBAction func cancelEditor(_ sender: Any) {
        
        // return to previous tab or collection overview
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

// MARK: UITextFieldDelegate
extension MemeEditorViewController: UITextFieldDelegate {
    
    // when the text field get's the focus
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        // if the entered text equals one of the two default texts
        if (textField.text=="TOP" || textField.text=="BOTTOM") {
            
            // clear the text field
            textField.text = ""
        }
        
        //return self.editingSwitch.isOn
        return true
    }
    
    // when the text field looses focus
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}

// MARK: UIImagePickerControllerDelegate
extension MemeEditorViewController: UIImagePickerControllerDelegate {
    
    // image selected
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo: [String : Any]) {
        
        // extract selected image
        if let image = didFinishPickingMediaWithInfo["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            // show image
            imageView.image = image as UIImage
                        
            // enable share button
            self.dismiss(animated: true, completion: { () -> Void in
                self.shareButton.isEnabled = true
            })
        }
        else {
            print("Error displaying selected image")
        }
    }
    
    // image selection cancelled
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        
        // close picker
        dismiss(animated: true, completion: nil)
    }
}
