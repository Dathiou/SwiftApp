//
//  homeVC.swift
//  StickerSpread
//
//  Created by Student iMac on 5/27/16.
//  Copyright © 2016 Student iMac. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit
import FirebaseAuth
import Firebase




class homeVC: UICollectionViewController {
    
    let storage = FIRStorage.storage()
    let storageRef = FIRStorage.storage().referenceForURL("gs://stickerspread-4f3a9.appspot.com")
    
    // refresher variable
    var refresher : UIRefreshControl!
    
    // size of page
    var page : Int = 12
    
    // arrays to hold server information
    var uuidArray = [String]()
    //var picArray = [PFFile]()
    
    var usernameArray = [String]()
    //var avaArray = [PFFile]()
    //var avaArrayF = [UIImage]()
    var avaArray = [UIImage]()
    var postpicArraySearch = [PFFile]()
    var nameArray = [String]()
    var nameArraySearch = [String]()
    var dateArray = [NSDate?]()
    var dateArraySearch = [NSDate?]()
    //var picArray = [PFFile]()
    //var picArrayF = [UIImage]()
    var picArray = [UIImage]()
    var picArraySearch = [PFFile]()
    var uuidArraySearch = [String]()
    var titleArray = [String]()
    var titleArraySearch = [String]()
    //var uuidArray = [String]()
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // always vertical scroll
        self.collectionView?.alwaysBounceVertical = true
//background
        collectionView?.backgroundColor = .whiteColor()
        
        //title at the top
        self.navigationItem.title=(PFUser.currentUser()!.objectForKey("first_name") as? String)?.uppercaseString

        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
        
        //receive notification from uploadVC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploaded:", name: "uploaded", object: nil)
        
        // load posts func
        loadPosts()
    }
    
    
    // refreshing func
    func refresh() {
        
        // reload posts
        //loadPosts()
        collectionView?.reloadData()
        
        // stop refresher animating
        refresher.endRefreshing()
    }
    
    func uploaded(notification: NSNotification){
        loadPosts()
    }
    
//    
//    // load posts func
//    func loadPosts() {
//        
//        // request infomration from server
//        let query = PFQuery(className: "posts")
//        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
//        query.limit = page
//        query.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
//            if error == nil {
//                
//                // clean up
//                self.uuidArray.removeAll(keepCapacity: false)
//                self.picArray.removeAll(keepCapacity: false)
//                
//                // find objects related to our request
//                for object in objects! {
//                    
//                    // add found data to arrays (holders)
//                    self.uuidArray.append(object.valueForKey("uuid") as! String)
//                    self.picArray.append(object.valueForKey("pic") as! PFFile)
//                }
//                self.collectionView?.reloadData()
//            } else {
//                print(error!.localizedDescription)
//            }
//        })
//    }
//    
    
//    // load more while scrolling down
//    override func scrollViewDidScroll(scrollView: UIScrollView) {
//        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
//            loadMore()
//        }
//    }
    
//    
//    // paging
//    func loadMore() {
//        
//        // if there is more objects
//        if page <= picArray.count {
//            
//            // increase page size
//            page = page + 12
//            
//            // load more posts
//            let query = PFQuery(className: "posts")
//            query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
//            query.limit = page
//            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
//                if error == nil {
//                    
//                    // clean up
//                    self.uuidArray.removeAll(keepCapacity: false)
//                    self.picArray.removeAll(keepCapacity: false)
//                    
//                    // find related objects
//                    for object in objects! {
//                        self.uuidArray.append(object.valueForKey("uuid") as! String)
//                        self.picArray.append(object.valueForKey("pic") as! PFFile)
//                    }
//                    
//                    self.collectionView?.reloadData()
//                    
//                } else {
//                    print(error?.localizedDescription)
//                }
//            })
//            
//        }
//        
//    }
    
    
    
    // load posts
    func loadPosts() {

        firebase.child("PostPerUser").child((FIRAuth.auth()?.currentUser?.uid)!).queryOrderedByChild("date").observeEventType(.Value, withBlock: { snapshot in
            
            // clean up
            self.usernameArray.removeAll(keepCapacity: false)
            self.nameArray.removeAll(keepCapacity: false)
            self.avaArray.removeAll(keepCapacity: false)
            self.dateArray.removeAll(keepCapacity: false)
            self.picArray.removeAll(keepCapacity: false)
            //self.picArraySearch.removeAll(keepCapacity: false)
            self.titleArray.removeAll(keepCapacity: false)
            self.uuidArray.removeAll(keepCapacity: false)
            
            if snapshot.exists() {
                for post in snapshot.children{
                    let userID = post.value.objectForKey("userID") as! String
                    self.storage.referenceForURL(post.value.objectForKey("photoUrl") as! String).dataWithMaxSize(25 * 1024 * 1024, completion: { (data, error) -> Void in
                        let image = UIImage(data: data!)
  
                        self.picArray.append(image! as! UIImage)
                        
                        //objc_sync_exit(self.nameArray)
                        //self.tableView.reloadData()
                        //self.scrollToBottom()
                        firebase.child("Users").child(userID).observeEventType(.Value, withBlock: { snapshot in
                            
                            let first = (snapshot.value!.objectForKey("first_name") as? String)
                            let last = (snapshot.value!.objectForKey("last_name") as? String)
                            
                            let fullname = first!+" "+last!
                            self.nameArray.append(fullname)
                           // self.tableView.reloadData()
                           // self.collectionView.reloadData()
                            let avaURL = (snapshot.value!.objectForKey("ProfilPicUrl") as! String)
                            let url = NSURL(string: avaURL)
                            if let data = NSData(contentsOfURL: url!){ //make sure your image in this url does exist, otherwise unwrap in a if let check
                                self.avaArray.append(UIImage(data: data) as UIImage!)
                                
                            }
                            
                            //self.comments.append(snapshot)
                            //self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.comments.count-1, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
                            }
                            
                            
                        ){ (error) in
                            print(error.localizedDescription)
                        }
                        
                        // objc_sync_exit(self.nameArray)
                        
                    })
                    
                    //let datestring = post.value.objectForKey("date") as! String
                    if let datestring = post.value.objectForKey("date") as? String{
                        var dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                        let date = dateFormatter.dateFromString(datestring)
                        self.dateArray.append(date)
                    }
                    self.usernameArray.append(userID as! String)
                    
                    self.titleArray.append(post.value.objectForKey("title") as! String)
                    self.uuidArray.append(post.key! as String!)
                    
                    
                    
                    // dispatch_async(dispatch_get_main_queue(), {
                    //  self.tableView.reloadData()
                    //self.collectionView.reloadData()
                    self.refresher.endRefreshing()
                    // });
                    
                    
                    
                    
                }}
            
            
            
            
            
            
            //self.comments.append(snapshot)
            //self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.comments.count-1, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    
    
    
    // cell numb
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    // cell size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    // cell config
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! testsearchcell
        
//        // get picture from the picArray
//        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
//            if error == nil {
//                cell.picImg.image = UIImage(data: data!)
//            } else {
//                print(error!.localizedDescription)
//            }
        
            cell.picImg1.image = picArray[indexPath.row]
       // }
        
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        //define header
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! headerView
        
       
            //let image = UIImage(data: data!)
            
            // objc_sync_enter(self.nameArray)
            // objc_sync_enter(self.nameArray)
           // self.picArray.append(image! as! UIImage)
            
            //objc_sync_exit(self.nameArray)
            //self.tableView.reloadData()
            //self.scrollToBottom()
            firebase.child("Users").child((FIRAuth.auth()?.currentUser!.uid)!).observeEventType(.Value, withBlock: { snapshot in
                
                let first = (snapshot.value!.objectForKey("first_name") as? String)
                let last = (snapshot.value!.objectForKey("last_name") as? String)
                
                header.fullnameLbl.text  = first!+" "+last!
         
                let avaURL = (snapshot.value!.objectForKey("ProfilPicUrl") as! String)
                let url = NSURL(string: avaURL)
                if let data = NSData(contentsOfURL: url!){ //make sure your image in this url does exist, otherwise unwrap in a if let check
                    header.avaImg.image = UIImage(data: data)
                    
                }

                }
                
                
            ){ (error) in
                print(error.localizedDescription)
            }
       
        
        

        
        if let web = PFUser.currentUser()?.objectForKey("web") as? String {
            header.webTxt.text = web
            header.webTxt.sizeToFit()
        }
        
        if let bio = PFUser.currentUser()?.objectForKey("bio") as? String {
            header.bioLbl.text = bio
            header.bioLbl.sizeToFit()
        }
     
        
        let avaQuery = PFUser.currentUser()?.objectForKey("picture_file") as! PFFile
        avaQuery.getDataInBackgroundWithBlock {(data:NSData?, error:NSError?) -> Void in
            header.avaImg.image = UIImage(data:data!)
        }
        header.button.setTitle("edit profile", forState: UIControlState.Normal)

        
        // STEP 2. Count statistics
        // count total posts
//        let posts = PFQuery(className: "posts")
//        posts.whereKey("username", equalTo: PFUser.currentUser()!.username!)
//        posts.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
//            if error == nil {
//                header.posts.text = "\(count)"
//            }
//        })
        
        
        
        firebase.child("LikesPerUser").child((FIRAuth.auth()?.currentUser!.uid)!).observeEventType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                
                header.posts.text =  "\(snapshot.childrenCount)"
                
            }
        })
        
        
        // count total followers
//        let followers = PFQuery(className: "follow")
//        followers.whereKey("following", equalTo: PFUser.currentUser()!.username!)
//        followers.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
//            if error == nil {
//                header.followers.text = "\(count)"
//            }
//        })
        
        firebase.child("Followers").child((FIRAuth.auth()?.currentUser!.uid)!).observeEventType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                header.followers.text =  "\(snapshot.childrenCount)"
            }
        })
        
        
        
        // count total followings
//        let followings = PFQuery(className: "follow")
//        followings.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
//        followings.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
//            if error == nil {
//                header.followings.text = "\(count)"
//            }
//        })
        
        firebase.child("Followings").child((FIRAuth.auth()?.currentUser!.uid)!).observeEventType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                header.followings.text =  "\(snapshot.childrenCount)"
            }
        })

        // STEP 3. Implement tap gestures
        // tap posts
        let postsTap = UITapGestureRecognizer(target: self, action: "postsTap")
        postsTap.numberOfTapsRequired = 1
        header.posts.userInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        // tap followers
        let followersTap = UITapGestureRecognizer(target: self, action: "followersTap")
        followersTap.numberOfTapsRequired = 1
        header.followers.userInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        // tap followings
        let followingsTap = UITapGestureRecognizer(target: self, action: "followingsTap")
        followingsTap.numberOfTapsRequired = 1
        header.followings.userInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        
        return header
    }
    
    
    // taped posts label
    func postsTap() {
        if !picArray.isEmpty {
            let index = NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
    }
    
    // tapped followers label
    func followersTap() {
        
        user = (FIRAuth.auth()?.currentUser!.uid)!
        show = "followers"
        
        // make references to followersVC
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        // present
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    // tapped followings label
    func followingsTap() {
        
        user = (FIRAuth.auth()?.currentUser!.uid)!
        show = "followings"
        
        // make reference to followersVC
        let followings = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        // present
        self.navigationController?.pushViewController(followings, animated: true)
    }

    //clicked logout
    @IBAction func logout(sender: AnyObject) {
        // implement log out
        let loginManager = FBSDKLoginManager()
        loginManager.logOut() // this is an instance function
        print("logged out from FB")
        try! FIRAuth.auth()!.signOut()
        PFUser.logOut()
        let signin = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = signin
        
//        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
//            if error == nil {
//                
//                // remove logged in user from App memory
//                NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
//                NSUserDefaults.standardUserDefaults().synchronize()
//                
//                let signin = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
//                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                appDelegate.window?.rootViewController = signin
//                
//            } else
//            {
//                print("parse log out failed")
//            }
//        }
        
    }
    
    
    // go post
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // send post uuid to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        
        // navigate to post view controller
        let post = self.storyboard?.instantiateViewControllerWithIdentifier("postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    @IBAction func settingsBtn_clicked(sender: AnyObject) {
        
        
    }
   
  
}
