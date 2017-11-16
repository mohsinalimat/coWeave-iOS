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
    var page : Page!
    var pageImage : Image! = nil
    var pageNumber: Int16 = 1
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
        self.navigationItem.title = document.name
        updatePageControls(page: page)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func previousPage(_ sender: Any) {
        resetPage()
        if (page.previous != nil) {
            page = page.previous
        }
        updatePage(page: page)
        updatePageControls(page: page)
    }
    
    @IBAction func nextPage(_ sender: Any) {
        resetPage()
        if (page.next == nil) {
            self.pageNumber = pageNumber + 1
            page = createPage(number: pageNumber, previous: page, doc: self.document)
        } else {
            page = page.next
        }
        updatePage(page: page)
        updatePageControls(page: page)
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
        
        page = createPage(number: 1, doc: document)
        
        return document
    }
    
    func createPage(number: Int16, previous: Page? = nil, doc: Document) -> Page {
        // Create Entity
        let entity = NSEntityDescription.entity(forEntityName: "Page", in: self.managedObjectContext)
        
        // Initialize Record
        let page = Page(entity: entity!, insertInto: self.managedObjectContext)
        
        page.addedDate = NSDate()
        page.number = number
        page.document = doc
        page.previous = previous
        
        if (previous != nil) {
            previous!.next = page
        }
        
        do {
            // Save Record
            try page.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
        return page
    }
    
    func resetPage() {
        self.image = nil
        self.backgroundImageView.image = nil
        self.pageImage = nil
    }
    
    func updatePageControls(page: Page) {
        self.previousPageButton.isEnabled = (page.previous != nil) ? true : false;
        self.nextPageButton.isEnabled = true // always enabled, because we can add as many pages as we want
        self.pageNameButton.title = "Page \(page.number)"
    }
    
    func updatePage(page: Page) {
        if (page.image != nil) {
            self.image = UIImage(data: page.image!.image! as Data, scale: 1.0)
            self.backgroundImageView.image = self.image
            self.pageImage = page.image!
        }
    }
    
    /**
     * Save Image
     */
    
    func doneEditing(image: UIImage) {
        self.image = image;
        self.backgroundImageView.image = image;
        pageImage = createImage(imageValue: image, previous: pageImage, page: self.page)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        backgroundImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.image = backgroundImageView.image
        pageImage = createImage(imageValue: image, previous: pageImage, page: self.page)
        self.drawText()
    }
    
    func createImage(imageValue: UIImage, previous: Image? = nil, page: Page) -> Image {
        // Create Entity
        let entity = NSEntityDescription.entity(forEntityName: "Image", in: self.managedObjectContext)
        
        // Initialize Record
        let image = Image(entity: entity!, insertInto: self.managedObjectContext)
        let imageData: NSData = UIImagePNGRepresentation(imageValue)! as NSData
        
        image.addedDate = NSDate()
        image.image = imageData
        image.previous = previous
        image.page = page
        
        if (previous != nil) {
            previous!.next = image
        }
        
        do {
            // Save Record
            try image.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
        return image
    }
    
    
    /**
     * Help Functions for Draw
     */
    
    func drawText() {
        if (self.image == nil) {
            self.image = UIImage(color: .white, size: CGSize(width: 1536, height: 2048))
            pageImage = createImage(imageValue: self.image, page: self.page)
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
    
    func canceledEditing() {
        print("Canceled")
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "home") {
            let classVc = segue.destination as! RootTabBarViewController
            classVc.managedObjectContext = self.managedObjectContext
        }
    }

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
