//
//  DetailViewController.swift
//  TikTokClone
//
//  Created by apple on 01.09.2023.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var postId = ""
    var post = Post()
    var user = User()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        loadPost()
    }
    //MARK: - Functions
    
     func loadPost() {
         Api.Post.observeSinglePost(postId: postId) { post in
             guard let postUid = post.uid else { return }
             
             self.fetchUser(uid: postUid) {
                 self.post = post
                 self.collectionView.reloadData()
             }
         }
    }
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(withId: uid) { user in
            self.user = user
            completed()
        }
    }
    
}


//MARK: -

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
        cell.post = post
        cell.user = user
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
