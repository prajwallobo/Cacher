//
//  PinboardViewController.swift
//  Cacher
//
//  Created by Prajwal Lobo on 18/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import UIKit

class PinboardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //MARK:- Property
    var users = [Pin]()
    private var refreshControl = UIRefreshControl()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
        registerCell()
        setupUI()

    }
    //MARK:-
    func registerCell(){
        collectionView.register(UserCollectionViewCell.loadNib(), forCellWithReuseIdentifier: "UserCollectionViewCell")
    }
    //MARK:-
    func setupUI(){
        navigationItem.title = "Users Board"
        
        //Adding refresh control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = UIColor.gray
        let attribute = [NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.font: UIFont(name: "KohinoorDevanagari-Medium", size: 12.0)!]
        refreshControl.attributedTitle = NSAttributedString(string: "Rereshing Changes", attributes: attribute)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
    }
    
    //MARK:- CollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionViewCell", for: indexPath) as! UserCollectionViewCell
        let user = users[indexPath.item]
        cell.nameLabel.text = user.user?.name
        if let profileImage = user.user?.profileImage?.large{
            cell.profileImageView.setImage(with: URL(string : profileImage))
        }
        cell.likeLabel.text = "\(user.likes ?? 0)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userPin = users[indexPath.item]
        performSegue(withIdentifier: "LoadUserPhotoSegue", sender: userPin)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       // guard let aCell = cell as? UserCollectionViewCell else {return}
        //aCell.profileImageView.cancelDownloadTask()
        
    }
    
    //MARK:- Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segue = segue.destination as? PhotoViewController{
            let pin = sender as! Pin
            segue.pin = pin
        }
    }
    
    //MARK:- API to get Users
    func getUsers(){
        APIService.shared.getPin {[weak self] (pin, error) in
            guard let ref = self else {return}
            if let error = error{
                if let message = error.message{
                    print(message)
                }
            }else{
                if let userPin = pin{
                    if ref.refreshControl.isRefreshing{
                        ref.users.removeAll(keepingCapacity: true)
                        ref.users.append(contentsOf: userPin)
                        ref.collectionView.reloadData()
                        ref.refreshControl.endRefreshing()
                    }else{
                        ref.users.removeAll()
                        ref.users.append(contentsOf: userPin)
                        ref.collectionView.reloadData()
                    }
                }
            }
        }
    }
    //MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: (width - 15)/2, height: (width - 15)/2) //5 left and right spacing X 2 + cellspace
    }
    
    //MARK:- Refresh Control
    @objc func refreshData(){
        getUsers()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
