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
import AVFoundation

class DocumentDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoEditorDelegate {
    var image : UIImage!
    var imagePicker = UIImagePickerController()
    var document : Document? = nil
    var page : Page!
    var pageImage : Image! = nil
    var pageNumber: Int16 = 1
    var managedObjectContext: NSManagedObjectContext!
    /**
     *  Audio Recorder
     */
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    var meterTimer:Timer!
    var soundFileURL:URL!
    var audio : Bool = false
    var playing : Bool = false
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
    @IBOutlet var undoButton: UIBarButtonItem!
    @IBOutlet var redoButton: UIBarButtonItem!
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
        
        //create new doc
        if (document == nil) {
            document = createDocument()
        } else {
            self.pageNumber = Int16(document!.pages!.count)
            self.page = document?.pages!.allObjects[(self.pageNumber - 1)] as! Page
            updatePage(page: self.page)
        }
        
        self.navigationItem.title = document?.name!
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
        print("audio")
        if audio && !playing { // if sound recorded, play it.
            startPlay()
            return
        }
        if playing {
            print("stopping")
            stopPlay()
            return
        }
        if (!audio) {
            if recorder == nil {
                print("recording. recorder nil")
                self.audioButton.setImage(UIImage(named: "stop"), for: .normal)
        
                recordWithPermission(true)
                return
            }
        }
        if recorder != nil && recorder.isRecording {
            print("\(#function)")
        
            recorder?.stop()
            player?.stop()
            
            meterTimer.invalidate()
            
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setActive(false)
            } catch {
                print("could not make session inactive")
                print(error.localizedDescription)
            }
        }
    }
    
    
    func startPlay() {
        play()
        self.audioButton.setImage(UIImage(named: "stop"), for: .normal)
        playing = true
    }
    
    func stopPlay() {
        player.stop()
        self.audioButton.setImage(UIImage(named: "play"), for: .normal)
        playing = false
    }
    
    
    func updateAudioMeter(_ timer:Timer) {
        if let recorder = self.recorder {
            if recorder.isRecording {
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
                self.audioButton.setTitle(s, for: .normal)
                recorder.updateMeters()
            }
        }
    }
    
    func play() {
        print("\(#function)")
        var url:URL?
        if self.recorder != nil {
            url = self.recorder.url
        } else {
            url = self.soundFileURL!
        }
        print("playing \(String(describing: url))")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url!)
            self.audioButton.imageView?.image = UIImage(named: "stop")
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch {
            self.player = nil
            print(error.localizedDescription)
        }
        
    }
    
    
    func setupRecorder() {
        print("\(#function)")
        
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).m4a"
        print(currentFileName)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        print("writing to soundfile url: '\(soundFileURL!)'")
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings:[String : Any] = [
            AVFormatIDKey:             kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey :      32000,
            AVNumberOfChannelsKey:     2,
            AVSampleRateKey :          44100.0
        ]
        
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    func recordWithPermission(_ setup:Bool) {
        print("\(#function)")
        
        AVAudioSession.sharedInstance().requestRecordPermission() {
            [unowned self] granted in
            if granted {
                
                DispatchQueue.main.async {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                           target:self,
                                                           selector:#selector(self.updateAudioMeter(_:)),
                                                           userInfo:nil,
                                                           repeats:true)
                }
            } else {
                print("Permission to record not granted")
            }
        }
        
        if AVAudioSession.sharedInstance().recordPermission() == .denied {
            print("permission denied")
        }
    }
    
    func setSessionPlayback() {
        print("\(#function)")
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback, with: .defaultToSpeaker)
            
        } catch {
            print("could not set session category")
            print(error.localizedDescription)
        }
        
        do {
            try session.setActive(true)
        } catch {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func setSessionPlayAndRecord() {
        print("\(#function)")
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        } catch {
            print("could not set session category")
            print(error.localizedDescription)
        }
        
        do {
            try session.setActive(true)
        } catch {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func askForNotifications() {
        print("\(#function)")
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(DocumentDetailViewController.background(_:)),
                                               name:NSNotification.Name.UIApplicationWillResignActive,
                                               object:nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(DocumentDetailViewController.foreground(_:)),
                                               name:NSNotification.Name.UIApplicationWillEnterForeground,
                                               object:nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(DocumentDetailViewController.routeChange(_:)),
                                               name:NSNotification.Name.AVAudioSessionRouteChange,
                                               object:nil)
    }
    
    func background(_ notification:Notification) {
        print("\(#function)")
        
    }
    
    func foreground(_ notification:Notification) {
        print("\(#function)")
        
    }
    
    
    func routeChange(_ notification:Notification) {
        print("\(#function)")
        
        if let userInfo = (notification as NSNotification).userInfo {
            print("routeChange \(userInfo)")
            
            //print("userInfo \(userInfo)")
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                //print("reason \(reason)")
                switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
                case AVAudioSessionRouteChangeReason.newDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.oldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.categoryChange:
                    print("CategoryChange")
                case AVAudioSessionRouteChangeReason.override:
                    print("Override")
                case AVAudioSessionRouteChangeReason.wakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSessionRouteChangeReason.unknown:
                    print("Unknown")
                case AVAudioSessionRouteChangeReason.noSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSessionRouteChangeReason.routeConfigurationChange:
                    print("RouteConfigurationChange")
                    
                }
            }
        }
    }
    
    func checkHeadphones() {
        print("\(#function)")
        
        // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count > 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphones are plugged in")
                    break
                } else {
                    print("headphones are unplugged")
                }
            }
        } else {
            print("checking headphones requires a connection to a device")
        }
    }
    
    @IBAction func drawAction(_ sender: Any) {
       self.drawText()
    }
    
    @IBAction func textAction(_ sender: Any) {
       self.drawText()
    }
    
    func createDocument() -> Document {
        // Create Entity
        let entity = NSEntityDescription.entity(forEntityName: "Document", in: self.managedObjectContext)
        
        // Initialize Record
        let document = Document(entity: entity!, insertInto: self.managedObjectContext)
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "dd.MM.yyyy"
        
        document.addedDate = NSDate()
        document.name = "Document \(formatter.string(from: NSDate() as Date))"
        
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
        self.nextPageButton.image = (page.next == nil) ? UIImage(named: "right-add") : UIImage(named: "right")
        self.pageNameButton.title = "Page \(page.number)"
        
        self.audioButton.imageView?.image = (page.audio == nil) ? UIImage(named: "micro") : UIImage(named: "play")
    }
    
    func updatePage(page: Page) {
        if (page.image != nil) {
            self.image = UIImage(data: page.image!.image! as Data, scale: 1.0)
            self.backgroundImageView.image = self.image
            self.pageImage = page.image!
        }
        updateImageControls(image: pageImage)
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
            page = createPage(number: pageNumber, previous: page, doc: self.document!)
        } else {
            page = page.next
        }
        updatePage(page: page)
        updatePageControls(page: page)
    }
    
    /**
     * Save Image
     */
    
    func doneEditing(image: UIImage) {
        self.image = image;
        self.backgroundImageView.image = image;
        pageImage = createImage(imageValue: image, previous: pageImage, page: self.page)
        updateImageControls(image: pageImage)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        backgroundImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.image = backgroundImageView.image
        pageImage = createImage(imageValue: image, previous: pageImage, page: self.page)
        updateImageControls(image: pageImage)
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
     * Undo and Redo Actions on Images.
     */
    
    func updateImageControls(image: Image? = nil) {
        if (image == nil) {
            self.undoButton.isEnabled = false;
            self.redoButton.isEnabled = false;
        } else {
            self.undoButton.isEnabled = (image?.previous != nil) ? true : false;
            self.redoButton.isEnabled = (image?.next != nil) ? true : false;
        }
    }
    
    @IBAction func undoAction(_ sender: Any) {
        if (pageImage != nil) {
            if (pageImage.previous != nil) {
                self.image = UIImage(data: pageImage.previous!.image! as Data, scale: 1.0)
                self.backgroundImageView.image = self.image
                self.pageImage = pageImage.previous!
                updateImageControls(image: pageImage)
            }
        }
    }
    
    @IBAction func redoAction(_ sender: Any) {
        if (pageImage != nil) {
            if (pageImage.next != nil) {
                self.image = UIImage(data: pageImage.next!.image! as Data, scale: 1.0)
                self.backgroundImageView.image = self.image
                self.pageImage = pageImage.next!
                updateImageControls(image: pageImage)
            }
        }
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
        if (segue.identifier == "pages") {
            let classVc = segue.destination as! PagesTableViewController
            classVc.managedObjectContext = self.managedObjectContext
            classVc.document = self.document
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



// MARK: AVAudioRecorderDelegate
extension DocumentDetailViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
                                         successfully flag: Bool) {
        
        print("\(#function)")
        
        print("finished recording \(flag)")
        self.play()
        
        //recordButton.setTitle("Record", for:UIControlState())
        
        // iOS8 and later
        let alert = UIAlertController(title: "Playing recorded audio....",
                                      message: "Would you like to keep or delete?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Keep", style: .default, handler: {action in
            print("keep was tapped")
            self.recorder = nil
            self.audio = true
            
            self.audioButton.setImage(UIImage(named: "play"), for: .normal)
            self.audioButton.setTitle("", for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
            print("delete was tapped")
            self.recorder.deleteRecording()
            self.audio = false
            self.recorder = nil
            self.soundFileURL = nil
            
            self.audioButton.setImage(UIImage(named: "micro"), for: .normal)
            self.audioButton.setTitle("", for: .normal)
        }))
        self.present(alert, animated:true, completion:nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
                                          error: Error?) {
        print("\(#function)")
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
    
}

// MARK: AVAudioPlayerDelegate
extension DocumentDetailViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("\(#function)")
        
        print("finished playing \(flag)")
        self.audioButton.setImage(UIImage(named: "play"), for: .normal)
        self.audioButton.setTitle("", for: .normal)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("\(#function)")
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
        
    }
}
