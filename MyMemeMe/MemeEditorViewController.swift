//
//  ViewController.swift
//  MyMemeMe
//
//  Created by Edwin de Jongh on 19/07/2017.
//  Copyright © 2017 Dev66. All rights reserved.
//
// Test commit from XCode

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: outlets
    
    // handle to relevant UI elements
    @IBOutlet weak var actionsToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var optionsToolbar: UIToolbar!
    @IBOutlet weak var pickButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
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
        
        // create textfield properties dictionary to use
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -1.0]
        
        // set textfield properties
        self.topTextField.defaultTextAttributes = memeTextAttributes
        self.bottomTextField.defaultTextAttributes = memeTextAttributes
        
        // init textfield texts
        self.topTextField.text = "TOP";
        self.bottomTextField.text = "BOTTOM";
        
        // set alignment property
        self.topTextField.textAlignment = NSTextAlignment.center
        self.bottomTextField.textAlignment = NSTextAlignment.center
        
        // set delegates
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self
    }
    
    // open foto selection
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    // open camera app
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    // image selected
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo: [String : Any]) {
        
        // extract selected image
        if let image = didFinishPickingMediaWithInfo["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            // show image
            imageView.image = image as UIImage
            
            // TMP - faster debugging
            //self.save()
            //print("TMP Saved")
            
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
        
        view.frame.origin.y -= getKeyboardHeight(notification)
    }

    func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: Text Field Delegate

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
    
    // MARK: Meme object saving, sharing
    
    // generate memed image from current screen
    func generateMemedImage() -> UIImage {
        
        // hide toolbar and navbar
        self.actionsToolbar.isHidden = true
        self.optionsToolbar.isHidden = true
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // show toolbar and navbar
        self.actionsToolbar.isHidden = false
        self.optionsToolbar.isHidden = false
        
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

                // dismiss self
                imageSharer.dismiss(animated: true)
                
                // redirect to tab controller start page
                let start = self.storyboard!.instantiateViewController(withIdentifier: "MemeTabController")
                self.present(start, animated: true, completion: nil)
                
            }
        }
        
        // show dialog
        present(imageSharer, animated: true, completion: nil)
    }
}

