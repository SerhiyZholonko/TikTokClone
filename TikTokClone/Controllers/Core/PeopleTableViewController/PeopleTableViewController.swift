//
//  PeopleTableViewController.swift
//  TikTokClone
//
//  Created by apple on 02.09.2023.
//

import UIKit

class PeopleTableViewController: UITableViewController {
    
    var users: [User] = []
    var searchController: UISearchController = UISearchController (searchResultsController: nil)
    var serarchResult: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUser()
        setupSearchController()
    }
    
    // MARK: - Table view data source
    
    func fetchUser() {
        Api.User.observeUsers { user in
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search users..."
        searchController.searchBar.barTintColor = UIColor.white
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? serarchResult.count : users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peopleCell", for: indexPath) as! PeopleTableViewCell
        let user =  searchController.isActive ? serarchResult[indexPath.row] : users[indexPath.row]
        cell.user = user
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) as? PeopleTableViewCell {
            let storybourd = UIStoryboard(name: "MainTabBar", bundle: nil)
            let profileUserVC = storybourd.instantiateViewController(identifier: "ProfileUserViewController") as! ProfileUserViewController
            guard let userId = users[indexPath.row].uid else { return }
            profileUserVC.userId = userId
            navigationController?.pushViewController(profileUserVC, animated: true)
//        }
    }
    
}


//MARK: -

extension PeopleTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == nil || searchController.searchBar.text!.isEmpty {
            view.endEditing (true)
        }else{
            let textLowercased = searchController.searchBar.text!.lowercased()
            filterContent(for: textLowercased)
        }
        tableView.reloadData()
    }
    func filterContent (for searchText: String) {
        serarchResult = self.users.filter{
            return $0.username!.lowercased().range(of: searchText) != nil
        }
    }
}




