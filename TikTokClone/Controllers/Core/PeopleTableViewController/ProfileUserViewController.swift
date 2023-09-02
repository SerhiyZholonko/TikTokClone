//
//  ProfileUserViewController.swift
//  TikTokClone
//
//  Created by apple on 02.09.2023.
//

import UIKit
import FirebaseAuth

class ProfileUserViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    var posts: [Post] = []
    var userId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
//        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchUser()
        fetchMyPosts()
    }
    //MARK: - Functions
    func fetchMyPosts() {
        Ref().databaseRoot.child("User-Posts").child(userId).observe(.childAdded) { snapshot in
            Api.Post.observeSinglePost(postId: snapshot.key) { post in
                self.posts.append(post)
                self.collectionView.reloadData()
            }
        }
    }
    func fetchUser() {
        Api.User.observeUser(withId: userId) { user in
            self.user = user
            self.collectionView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileUser_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postid = sender as! String
            detailVC.postId = postid
        }
    }

}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension ProfileUserViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostProfileCollectionViewCell",for: indexPath) as! PostProfileCollectionViewCell
        cell.delegate = self
        let post = posts[indexPath.item]
        cell.post = post
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind:kind,withReuseIdentifier:
                                                                                    "ProfileHeaderCollectionReusableView", for: indexPath) as! ProfileHeaderCollectionReusableView
            if let user = self.user {
                headerViewCell.user = user
            }
            headerViewCell.setupView()
            return headerViewCell
        }
        return UICollectionReusableView()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width  , height: collectionView.bounds.height / 2) // Adjust the width and height as needed.
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width / 3 - 30, height: size.height / 3)
    }
}

extension ProfileUserViewController: PostProfileCollectionViewCellDelegate {
    func goToDetailVC(postid: String) {
        performSegue(withIdentifier: "ProfileUser_DetailSegue", sender: postid)
    }
}
