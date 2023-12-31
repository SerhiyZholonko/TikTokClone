//
//  ProfileViewController.swift
//  TikTokClone
//
//  Created by apple on 30.08.2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    var posts: [Post] = []
    //MARK: - Livecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        fetchUser()
        fetchMyPosts()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
    //MARK: - Functions
    func fetchMyPosts() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
            
        Ref().databaseRoot.child("User-Posts").child(uid).observe(.childAdded) { snapshot in
            Api.Post.observeSinglePost(postId: snapshot.key) { post in
                self.posts.append(post)
                self.collectionView.reloadData()
            }
        }
    }
    func fetchUser() {
        Api.User.observeProfileUser { user in
            self.user = user
            self.collectionView.reloadData()
        }
    }
    
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        return CGSize(width: size.width / 3, height: size.height / 3)
    }
    
    @IBAction func editProfileDidTapped(_ sender: Any) {
        let storyboard = UIStoryboard (name: "MainTabBar", bundle: nil)
        let editvc = storyboard.instantiateViewController (withIdentifier: "EditProfileViewController") as! EditProfileViewController
        self.navigationController?.pushViewController(editvc,animated:true)
    }
}


extension ProfileViewController: PostProfileCollectionViewCellDelegate {
    func goToDetailVC(postid: String) {
        performSegue(withIdentifier: "Profile_DetailSegue", sender: postid)
    }
    
    
}
