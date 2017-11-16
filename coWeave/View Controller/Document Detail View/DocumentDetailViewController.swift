//
//  DocumentDetailViewController.swift
//  eduFresh
//
//  Created by Benoît Frisch on 15/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit
import iOSPhotoEditor
import MobileCoreServices
import CoreData

class DocumentDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoEditorDelegate {
    var image : UIImage!
    var imagePicker = UIImagePickerController()
    var document : Document!
    var managedObjectContext: NSManagedObjectContext!
    /**
     *  Center Buttons, to add new data.
     */
    @IBOutlet var photoButton: UIButton!
    @IBOutlet var galleryButton: UIButton!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var drawButton: UIButton!
    @IBOutlet var textButton: UIButton!
    /**
     *  Toolbar Buttons
     */
    @IBOutlet var previousPageButton: UIBarButtonItem!
    @IBOutlet var nextPageButton: UIBarButtonItem!
    @IBOutlet var pageNameButton: UIBarButtonItem!
    @IBOutlet var pagesListButton: UIBarButtonItem!
    /**
     *  Navigation Bar Buttons
     */
    @IBOutlet var previewButton: UIBarButtonItem!
    @IBOutlet var settingsButton: UIBarButtonItem!
    /**
     * Background
     */
    @IBOutlet var backgroundImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        document = createDocument()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createDocument() -> Document {
        // Create Entity
        let entity = NSEntityDescription.entity(forEntityName: "Document", in: self.managedObjectContext)
        
        // Initialize Record
        let document = Document(entity: entity!, insertInto: self.managedObjectContext)
        
        document.addedDate = NSDate()
        document.name = "New Document"
        
        do {
            // Save Record
            try document.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
        
        return document
    }
    
    // MARK: - IBActions

    @IBAction func photoAction(_ sender: Any) {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func galleryAction(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func audioAction(_ sender: Any) {
    }
    
    @IBAction func drawAction(_ sender: Any) {
       self.drawText()
    }
    
    @IBAction func textAction(_ sender: Any) {
       self.drawText()
    }
    
    /**
     * Help Functions for Camera Picker
     */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        backgroundImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.image = backgroundImageView.image
        self.drawText()
    }
    
    /**
     * Help Functions for Draw
     */
    
    func drawText() {
        if (self.image == nil) {
            self.image = UIImage(color: .white, size: CGSize(width: 1536, height: 2048))
        }
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        
        //PhotoEditorDelegate
        photoEditor.photoEditorDelegate = self
        
        //The image to be edited
        photoEditor.image = self.image
        
        //Optional: To hide controls - array of enum control
        photoEditor.hiddenControls = [.share, .save]
        
        //Stickers that the user will choose from to add on the image
        photoEditor.stickers.append(UIImage(named: "yellowCircle" )!)
        photoEditor.stickers.append(UIImage(named: "orangeCircle" )!)
        photoEditor.stickers.append(UIImage(named: "redCircle" )!)
        photoEditor.stickers.append(UIImage(named: "greenCircle" )!)
        photoEditor.stickers.append(UIImage(named: "blueCircle" )!)
        
        photoEditor.stickers.append(UIImage(named: "yellowTriangle" )!)
        photoEditor.stickers.append(UIImage(named: "orangeTriangle" )!)
        photoEditor.stickers.append(UIImage(named: "redTriangle" )!)
        photoEditor.stickers.append(UIImage(named: "greenTriangle" )!)
        photoEditor.stickers.append(UIImage(named: "blueTriangle" )!)
        
        photoEditor.stickers.append(UIImage(named: "yellowRectangle" )!)
        photoEditor.stickers.append(UIImage(named: "orangeRectangle" )!)
        photoEditor.stickers.append(UIImage(named: "redRectangle" )!)
        photoEditor.stickers.append(UIImage(named: "greenRectangle" )!)
        photoEditor.stickers.append(UIImage(named: "blueRectangle" )!)
        
        photoEditor.stickers.append(UIImage(named: "logo" )!)
        photoEditor.stickers.append(UIImage(named: "logo_white" )!)
        
        //Optional: Colors for drawing and Text, If not set default values will be used
        //photoEditor.colors = [.red,.blue,.green]
        
        //Present the View Controller
        present(photoEditor, animated: true, completion: nil)
    }
    
    
    func doneEditing(image: UIImage) {
        self.image = image;
        self.backgroundImageView.image = image;
    }
    
    func canceledEditing() {
        print("Canceled")
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
