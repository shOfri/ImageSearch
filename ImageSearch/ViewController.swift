//
//  ViewController.swift
//  ImageSearch
//
//  Created by Ofri Shadmi on 17/05/2023.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var GoBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var errorMessage: UILabel!
    
    let viewModel = SearchViewModel()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .fullScreen
        view.backgroundColor = .white
        
        setupCollectionView()
        changePlacehoderColor()
        setupView()
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                 flowLayout.itemSize = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
                 flowLayout.minimumLineSpacing = 10
                 flowLayout.minimumInteritemSpacing = 10
                 flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    
    override func viewWillAppear(_ animated : Bool){
        super.viewWillAppear(animated)
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
    }

    func setupView(){
        
        searchBar.text = UserDefaults.standard.string(forKey: "LastSearch") ?? ""
        searchBar.delegate = self

        searchBar.frame = CGRect(x: self.view.frame.minX + 20, y: self.view.frame.minY + 120, width: self.view.bounds.width - 33, height: 50)
        searchBar.searchTextField.textColor = .black.withAlphaComponent(0.7)
        
        if(searchBar.text != ""){
            searchImages()
        }
        
        GoBtn.center.x = view.frame.midX
        GoBtn.center.y = view.frame.minY + 150
        
        searchBar.center.x = view.frame.midX
        searchBar.center.y = view.frame.minY + 100
        
        errorMessage.center.x = view.frame.midX
        errorMessage.center.y = view.frame.midY
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let frameTable = CGRect(x: 10, y: view.frame.minY + 200, width: UIScreen.main.bounds.width - 20, height: keyboardHeight + 40)
                collectionView.frame = frameTable
        }
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.frame = CGRect(x: 10, y: view.frame.minY + 200, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - 200)
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
    }
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        
        dismissKeyboard()
        searchImages()
    }
    
    func searchImages() {
        
        viewModel.images = [] //reset images before next search
        
        guard let searchText = searchBar.text else { return }
        
        viewModel.searchText = searchText
        viewModel.currentPage = 1
        
        viewModel.performSearch { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async { [self] in
                    
                    if(self?.viewModel.images.count == 0){
                        self?.errorMessage.text = "Could not find images according this search"
                    }
                    self?.collectionView.reloadData()
                    UserDefaults.standard.set(searchText, forKey: "LastSearch")
                }
            case .failure(let error):
                self?.errorMessage.text = "Could not load images"
                self?.collectionView.reloadData()
                print("Search error: \(error)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
             return UICollectionViewCell()
         }
        
        if(viewModel.images.count > indexPath.item){
            let image = viewModel.images[indexPath.item]
            cell.configure(with: image)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let screenHeight = UIScreen.main.bounds.height
        let cellHeight = screenHeight * 0.15
        let imageResult = viewModel.images[indexPath.item]
        let width = calculateProportionalWidth(width: imageResult.webformatWidth, height: imageResult.webformatHeight)
        return CGSize(width: width, height: cellHeight)
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){

        let galleryViewController = ImageGalleryViewController(images: viewModel.images, selectedIndex: indexPath.item)
        present(galleryViewController, animated: true, completion: nil)
    }
    
    private func calculateProportionalWidth(width: Int, height: Int) -> CGFloat {
        let collectionViewWidth = collectionView.frame.width
        let cellWidth = (collectionViewWidth - 30) / 3
        let aspectRatio = CGFloat(width) / CGFloat(height)
        return cellWidth / aspectRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         
         let lastItem = viewModel.images.count - 1
         if indexPath.item == lastItem {
             viewModel.loadMoreImages(completion: {[weak self] result in
                 switch result {
                 case .success:
                     DispatchQueue.main.async {
                         self?.collectionView.reloadData()
                     
                     }
                 case .failure(let error):
                     print("Search error: \(error)")
                 }
                 
             })
             return
         }
     }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        errorMessage.text = ""
    }
    
    func changePlacehoderColor(){
        
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
        let attributedPlaceholder = NSAttributedString(string: "Search images...", attributes: placeholderAttributes)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = attributedPlaceholder
    }
}


extension UIViewController {

    func dismissKeyboard() {
        view.endEditing(true)
    }
}
