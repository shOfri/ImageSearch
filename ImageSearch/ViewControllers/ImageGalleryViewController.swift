
//  ImageGalleryViewController.swift
//  ImageSearch
//
//  Created by Ofri Shadmi on 17/05/2023.
//

import Foundation
import UIKit

class ImageGalleryViewController: UIViewController {
        
    private let images: [Image]
    private var selectedIndex: Int
        
    private var currentImageIndex: Int
        
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share Image", for: .normal)
        button.backgroundColor = .black.withAlphaComponent(0.8)
        button.layer.cornerRadius = 13
        return button
    }()
        
    init(images: [Image], selectedIndex: Int) {
        self.images = images
        self.selectedIndex = selectedIndex
        self.currentImageIndex = selectedIndex
            
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupView()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        imageView.addGestureRecognizer(swipeRight)
            
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        imageView.addGestureRecognizer(swipeLeft)

        displayImage(at: selectedIndex)
    }
    
    func setupView(){
        
        view.addSubview(imageView)
        imageView.frame = view.bounds
        imageView.isUserInteractionEnabled = true
        setImageOnFullScreen(imageView: imageView)
        
        view.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        shareButton.tintColor = .white
        shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shareButton.addTarget( self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
        
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right:
            showPreviousImage()
        case .left:
            showNextImage()
        default:
            break
        }
    }
        
    func showPreviousImage() {
        if currentImageIndex > 0 {
            currentImageIndex -= 1
            displayImage(at: currentImageIndex)
        }
    }
    
    func showNextImage() {
        if currentImageIndex < images.count - 1 {
            currentImageIndex += 1
            displayImage(at: currentImageIndex)
        }
    }
        
    func displayImage(at index: Int) {
        guard index >= 0 && index < images.count else { return }
        
        let image = images[index]
            
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

    @objc func shareButtonTapped() {
        
        guard let image = imageView.image else {
              return
            }
             
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    func setImageOnFullScreen(imageView: UIImageView) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = imageView.image

        imageViewBackground.contentMode = .scaleAspectFill

        view.addSubview(imageViewBackground)
        view.sendSubviewToBack(imageViewBackground)
    }
}

