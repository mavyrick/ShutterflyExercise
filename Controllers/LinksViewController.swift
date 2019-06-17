//
//  URLViewController.swift
//  ShutterflyExercise
//
//  Created by Josh Sorokin on 13/05/2019.
//  Copyright © 2019 Josh Sorokin. All rights reserved.
//

import UIKit

//  This table view presents the image link and the image ID. In the future I would like to have the table view also present a small thumbnail of the actual image so the user knows what image they are linking to. Another feature I would like to implement in the future is making a link be removed if the corresponding image is removed directly from Imagur.
class LinksViewController: UITableViewController {
    
    var photoArray: Array<PhotoData>?
    
    override func viewWillAppear(_ animated: Bool) {
        
        decodePropertyList()
        
        self.extendedLayoutIncludesOpaqueBars = true
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (photoArray?.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell", for: indexPath)
        
        let photoItem = photoArray?[indexPath.row]
        
        cell.textLabel?.text = photoItem?.link
        
        cell.detailTextLabel?.text = "ID: \(photoItem?.id ?? "")"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //  Open link in Safari
        if let url = URL(string: (photoArray?[indexPath.row].link ?? "http://i.imgur.com/")) {
            UIApplication.shared.open(url)
        }
        
    }
    
    func decodePropertyList() {
        
        let documentsDirectory =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask).first!
        
        let archiveURL = documentsDirectory.appendingPathComponent("links").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        
        //  Decode links.plist to model
        if let retrievedNoteData = try? Data(contentsOf: archiveURL),
            let decodedNote = try? propertyListDecoder.decode(Array<PhotoData>.self, from: retrievedNoteData) {
            
            self.photoArray = decodedNote
            
        }
        
    }
    
}
