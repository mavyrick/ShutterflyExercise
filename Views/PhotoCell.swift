//
//  PhotoCell.swift
//  ShutterflyExercise
//
//  Created by Josh Sorokin on 09/05/2019.
//  Copyright © 2019 Josh Sorokin. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var checkMark: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //  Prevent spinner and check mark from showing on reused cells
        spinner.isHidden = true
        checkMark.isHidden = true
        //  Make reused cells tappable
        isUserInteractionEnabled = true
        
    }
    
}
