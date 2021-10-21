//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Lauren Work on 10/16/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var posts = [PFObject]()
    var numberOfPosts: Int!
    var myRefreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        myRefreshControl = UIRefreshControl()
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //refreshing table
        loadPosts()
    }
    
    @objc func loadPosts(){
        numberOfPosts = 5
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = numberOfPosts
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { postsReturned, error in
            if postsReturned != nil {
                self.posts = postsReturned!
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }
        }
    }
    
    func loadMorePosts(){
        numberOfPosts += 5
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = numberOfPosts
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { postsReturned, error in
            if postsReturned != nil {
                self.posts = postsReturned!
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadMorePosts()
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.row]


        let user = post["author"] as! PFUser
        cell.authorLabel.text = user.username

        cell.captionLabel.text = post["caption"] as! String

        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!

        cell.photoView.af.setImage(withURL: url)

        return cell
        
    }

}
