//
//  ImageCell.swift
//  ImageSearch
//
//  Created by Ofri Shadmi on 17/05/2023.
//

import UIKit

class ImageCell: UICollectionViewCell {
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: contentView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
                
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
           
        imageView.frame = contentView.bounds
    }
    
    func configure(with image: Image) {
        // Load the image from the URL
        if let url = URL(string: image.webformatURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        let image = UIImage(data: data)
                        self.imageView.image = image
                    }
                }
            }
        }
    }
}

