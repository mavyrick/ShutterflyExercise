//
//  PhotosViewController.swift
//  ShutterflyExercise
//
//  Created by Josh Sorokin on 08/05/2019.
//  Copyright © 2019 Josh Sorokin. All rights reserved.
//

import UIKit
import Photos

class PhotosViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var photoArray = [UIImage]()
    
    var photoData: PhotoData?
    
    var cellState = [Int]()
    
    var imageWidth: CGFloat?
    
    //  Spinner that appears while photo library loads
    let libraryLoadSpinner: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Find most suitable image width for collection view images
        findImageWidth()
        
        //  Check that the app has access to the photo library
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.getPhotos()
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined")
            }
        }
        
        libraryLoadSpinner.color = UIColor.orange
        libraryLoadSpinner.frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
        libraryLoadSpinner.center = self.view.center
        self.view.addSubview(libraryLoadSpinner)
        libraryLoadSpinner.bringSubviewToFront(self.view)
        libraryLoadSpinner.startAnimating()
        
//        Prevents opaque navigation bar from pushing down view
        self.extendedLayoutIncludesOpaqueBars = true
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        //  Load images from library to collection view
        cell.photo.image = photoArray[indexPath.row]
        cell.spinner.isHidden = true
        
        //  This loops runs through the cellState array and changes the UI on the cell based on the cell state. Initial cell state is 0. When image is uploading and showing a spinner on the cell the state is 1. When image is uploaded and showing a check mark the cell state is 2. The purpose of this is to make sure views on cells are persistent when scrolling.
        for i in 0..<cellState.count {
            
            if indexPath.row == i && cellState[i] == 1 {
                cell.spinner.startAnimating()
                cell.spinner.isHidden = false
                cell.spinner.isHidden = false
                //  Prevent cell from being tapped again
                cell.isUserInteractionEnabled = false
            } else if indexPath.row == i && cellState[i] == 2 {
                cell.spinner.isHidden = true
                cell.spinner.stopAnimating()
                cell.checkMark.isHidden = false
                cell.isUserInteractionEnabled = false
            }
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width: CGFloat
        
        //  Set number of cells per row on portrait and landscape
        if UIDevice.current.orientation.isLandscape == true {
            width = (collectionView.frame.width / 5) - 1
        } else {
            width = (collectionView.frame.width / 3) - 1
        }
        
        return CGSize(width: width, height: width)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //  Change cell state to "uploading"
        if cellState[indexPath.row] == 0 {
            cellState[indexPath.row] = 1
        }
        
        collectionView.reloadItems(at: [indexPath])
        
        //  When cell is tapped get a high quality image of the same image shown on the cell.
        getHighQualityPhoto(indexPath: indexPath)
        
    }
    
    func findImageWidth() {
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        //  Fit the image to the approximate size of the largest cell to optimize image loading speed. Check whether portrait mode or landscape mode has larger cells.
        if (screenHeight / 5) >= (screenWidth / 3) {
            imageWidth = screenHeight / 5
        } else {
            imageWidth = screenWidth / 3
        }
        
    }
    
    func getPhotos() {
        
      
        let imageManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        //  Set to load synchronously. If this is set to asynchronous the majority of the photos do not load.
        requestOptions.isSynchronous = true
        requestOptions.resizeMode = .fast
        requestOptions.deliveryMode = .fastFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) {
            
            if fetchResult.count > 0 {
                
                // I have not yet optimized memory management for very large photo libraries so right now only up to 500 photos will be presented.
                var numPhotos: Int
                
                if fetchResult.count > 500 {
                    numPhotos = 500
                } else {
                    numPhotos = fetchResult.count
                }
                
                //  for i in 0..<fetchResult.count {
                for i in 0..<numPhotos {
                    
                    // Get the images as UIImages and load them to an array
                    imageManager.requestImage(for: fetchResult.object(at: i), targetSize: CGSize(width: (imageWidth ?? 150), height: imageWidth ?? 150), contentMode: .aspectFill, options: requestOptions, resultHandler:
                        
                        {
                            photo, error in
                            self.photoArray.append(photo!)
                    })
                    
                }
                
            }
            
            //  Create cellState array with the same number of elements as photoArray
            createCellStateArray()
            
            DispatchQueue.main.async {
                
                self.collectionView.reloadData()
                
                self.libraryLoadSpinner.isHidden = true
                self.libraryLoadSpinner.stopAnimating()
                
            }
            
        }
        
    }
    
    func getHighQualityPhoto(indexPath: IndexPath) {
        
        let imageManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) {
            
            //  Get a high quality UIImage based on the index path of the tapped cell
            imageManager.requestImage(for: fetchResult.object(at: indexPath.row), targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: requestOptions, resultHandler:
                
                {
                    photo, error in
                    
                    //  Convert the image to a png
                    guard let png = photo?.pngData() else { return }
                    
                    //  Convert the png to Base64
                    let pngBase64 = png.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
                    
                    //  Upload the png to Imagur
                    self.uploadPhoto(pngBase64: pngBase64, indexPath: indexPath)
                    
            })
            
        }
        
    }
    
    func uploadPhoto(pngBase64: String, indexPath: IndexPath) {
        
        //  Parameters for JSON body
        let parameters: [String : String] = [
            "image": pngBase64,
            "type": "base64",
        ]
        
        guard let imgurURL = URL(string: Constants.uploadURL) else { return }
        
        var request = URLRequest(url: imgurURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Constants.accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        
        request.httpBody = httpBody
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("response: \(responseJSON)")
            }
            guard let data = data else { return }
            
            do {
                
                let decoder = JSONDecoder()
                let base = try decoder.decode(Base.self, from: data)
                
                //  If request throws an error or if it does not work
                guard base.success == true else {
                    
                    //  Show an error box communicating an upload failure
                    let alert = UIAlertController(title: "Upload Failure", message: "There was a problem uploading your photo.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                    
                    return
                    
                }
                
                self.photoData = base.data
                
                DispatchQueue.main.async {
                    
                    self.cellState[indexPath.row] = 2
                    
                    self.collectionView.reloadItems(at: [indexPath])
                    
                    self.toPropertyList()
                    
                }
                
                return
                
            } catch let err {
                print("Err", err)
            }
            
        }
        
        task.resume()
        
    }
    
    func toPropertyList() {
        
        let documentDirectory =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask).first!
        
        //        Location of plist
        let archiveURL = documentDirectory.appendingPathComponent("links")
            .appendingPathExtension("plist")
        
        let documentDirectoryString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        
        //        Path used to check if plist file exists
        let path = documentDirectoryString.appending("/links.plist")
        
        if(!FileManager.default.fileExists(atPath: path)){
            
            //  If plist does not exist initialize it with initial photo data
            let propertyListEncoder = PropertyListEncoder()
            let encodedNote = try? propertyListEncoder.encode([self.photoData?.photoDataDictionary])
            try? encodedNote?.write(to: archiveURL,
                                    options: .noFileProtection)
            
            print("links.plist created")
            
        } else {
            
            //  If plist does exist convert it to an array of dictionaries and append a new photo data dictionary. Right now I did not do this in a most efficient way. With the way I did it I had to manually make the photo data dictionary conform to encodable protocol. To do this I had to make the keys and values of the dictionary be of type String. Therefore, if I needed a value of another type in the dictionary it would not be able to be encoded. Fortunately I only need String values for this app, but in the future I would like to find a better way to do this.
            
            let data = try! Data(contentsOf: archiveURL)
            
            var dataArray = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [[String : String]]
            
            let photoDataDict = self.photoData?.photoDataDictionary
            
            dataArray.append(photoDataDict!)
            
            print("dataArray: \(dataArray)")
            
            let optDataArray = Optional(dataArray)
            
            let propertyListEncoder = PropertyListEncoder()
            let encodedDataArray = try? propertyListEncoder.encode(optDataArray)
            try? encodedDataArray?.write(to: archiveURL,
                                         options: .noFileProtection)
            
            print("links.plist exists")
        }
        
    }
    
    func createCellStateArray() {
        
        for _ in 0..<photoArray.count {
            self.cellState.append(0)
        }
        
    }
    
}

//  Constants for API request
private struct Constants {
    static let uploadURL = "https://api.imgur.com/3/upload/"
    static let accessToken = "" // removed to protect sensitive information, ask me for token
}
