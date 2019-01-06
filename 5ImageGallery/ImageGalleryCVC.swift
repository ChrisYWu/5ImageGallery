//
//  ImageGalleryCVC.swift
//  5ImageGallery
//
//  Created by Chris Wu on 1/4/19.
//  Copyright © 2019 Wu Personal Team. All rights reserved.
//

import UIKit


class ImageGalleryCVC: UICollectionViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    // MARK: Model/Model Reference
    private var gallery = [ImageItem]()
    
    private var imageSizeRatioLookup = [URL: CGFloat]()
    
    private let reuseIdentifier = "ImageCell"
    private let placeHolderIdentifier = "PlaceHolderCell"
    private var cellWidth = CGFloat(200)
    private var flowLayout: UICollectionViewFlowLayout? {
        return collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    @IBOutlet var imageGalleryCollectionView: UICollectionView! {
        didSet {
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(adjustCollectionViewCellWidth(byHandlingGestureRecognizedBy:)))
            imageGalleryCollectionView.addGestureRecognizer(pinch)
            
            imageGalleryCollectionView.dragDelegate = self
            imageGalleryCollectionView.dropDelegate = self

        }
    }
    
    @objc func adjustCollectionViewCellWidth(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            var newWidth = cellWidth
            newWidth *= recognizer.scale
            newWidth = min(newWidth, imageGalleryCollectionView.bounds.size.width)
            if newWidth != cellWidth {
                cellWidth = newWidth
                flowLayout?.invalidateLayout()
            }
            recognizer.scale = 1.0
        default: break
        }
    }
    
    // View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        //        // Register cell classes
        //https://stackoverflow.com/questions/25165195/why-is-uicollectionviewcells-outlet-nil
        //        self.collectionView!.register(ImageGalleryCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: placeHolderIdentifier)
        
        // Do any additional setup after loading the view.
        
        // Tempolory Initialization Code for development
//        var url = URL(string: "https://image.freepik.com/free-vector/farm-landscape-flat-design_23-2147548119.jpg")
//        gallery.append(ImageItem(url: url!, aspectRatio: 0.5))
//        gallery.append(ImageItem(url: url!, aspectRatio: 1.5))
//        gallery.append(ImageItem(url: url!, aspectRatio: 2.8))
//
//        url = URL(string: "https://image.shutterstock.com/image-vector/vector-illustration-beautiful-fields-landscape-450w-1076134676.jpg")
//        gallery.append(ImageItem(url: url!, aspectRatio: 3.6))
//        gallery.append(ImageItem(url: url!, aspectRatio: 1.2))
//        gallery.append(ImageItem(url: url!, aspectRatio: 0.6))
//
//        url = URL(string: "https://images-na.ssl-images-amazon.com/images/I/71%2Bdn-XetGL._SL1500_.jpg")
//        gallery.append(ImageItem(url: url!, aspectRatio: 0.6))
//        gallery.append(ImageItem(url: url!, aspectRatio: 1.2))
//        gallery.append(ImageItem(url: url!, aspectRatio: 2.6))
//
//        print("The first image")
//        let temp = gallery[0].string!
//        print("gallery[0].string = \(temp)")
//
//        if let item = ImageItem(temp) {
//            print("item.url=\(item.url), item.aspectRatio=\(item.aspectRatio)")
//        }
        
        //        Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] timer in
        //            self?.cellWidth += 100
        //            self?.flowLayout?.invalidateLayout()
        //        })
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return gallery.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell
        if let imageCell = cell as? ImageGalleryCell {
            imageCell.imageItem = gallery[indexPath.item]
        }
        return cell
    }
    
    // MARK: UICollectionViewLayout Delegate
    @objc(collectionView:layout:sizeForItemAtIndexPath:)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = gallery[indexPath.item].aspectRatio * cellWidth
        let size = CGSize(width: cellWidth, height: height )
        return size
    }
    
    //MARK: UICollectionViewDrag Delegate
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItem(at: indexPath)
    }
    
    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        if let imgItem = (imageGalleryCollectionView.cellForItem(at: indexPath) as? ImageGalleryCell)?.imageItem {
            if let json = imgItem.string {
                let dragItem = UIDragItem(itemProvider: NSItemProvider(object: json))
                dragItem.localObject = imgItem
                return [dragItem]
            }
            else {
                return []
            }
        }
        else {
            return []
        }
    }
    
    // MARK: UICollectionViewDrop Delegate
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                //Has a sourceIndexPath, then must be a local D&D
                if let img = item.dragItem.localObject as? ImageItem {
                    collectionView.performBatchUpdates({
                        gallery.remove(at: sourceIndexPath.item)
                        gallery.insert(img, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            }
            else {
                let placeHolderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: placeHolderIdentifier))

                var rat : CGFloat?
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let img = image as? UIImage {
                        rat = img.size.height / img.size.width
                    }
                }
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (nsUrl, error) in
                    if let url = nsUrl as? URL, let ratio = rat {
                        let imgUrl = url.imageURL
                        //print("imgUrl=\(imgUrl), ratio=\(ratio)")
                        DispatchQueue.main.async {
                            placeHolderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.gallery.insert(ImageItem(url: imgUrl, aspectRatio: ratio), at: insertionIndexPath.item)
                            })
                        }
                    }
                    else {
                        placeHolderContext.deletePlaceholder()
                    }
                }
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self) || //local D&D - exchange position
         (session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)) //cross app D&D

    }
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext) as? UICollectionView == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
}
