//
//  ImageCollectionViewCell.swift
//  O2h-iOS-Assignment
//
//  Created by MD Faizan on 10/09/23.
//

import UIKit
import Kingfisher

final class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var imageView: UIImageView!
    
    func configureCell(with imageUrl: String) {
        let url = URL(string: imageUrl)
        let processor = DownsamplingImageProcessor(size: self.imageView.bounds.size)
        |> RoundCornerImageProcessor(cornerRadius: 20)
        self.imageView.kf.indicatorType = .activity
        
        self.imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: Constants.placeholderImage),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                DispatchQueue.main.async {
                    self.imageView.image = value.image
                }
                
            case .failure(let error):
                print(error)
                break
            }
        }
    }
}
