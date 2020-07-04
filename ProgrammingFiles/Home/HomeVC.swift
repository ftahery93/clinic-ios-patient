//
//  HomeVC.swift
//  NetLet
//
//  Created by Mohammed Yusuf Mitha on 02/03/20.
//  Copyright © 2020 Mohammed Yusuf Mitha. All rights reserved.
//

import UIKit
import Stevia

class HomeVC: Base , UISearchBarDelegate{

    var myTableView = UITableView()
    var reportIssueButton = UIButton()
    var reportedButton = UIButton()
    var approvedButton = UIButton()
    
    var currentButton : UIButton?
    var searchBar = UISearchBar()
    var fetchedIssues : DoctorModel?
    var filterData : DoctorModel?

    var refreshControl = UIRefreshControl()

    var logoutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(isloggedin == false){
            let dest = LoginVC()
            self.navigationController?.pushViewController(dest, animated: true)
        } else{
            token = UserDefaults.standard.string(forKey: "token")!
        }
        setUpView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchIssues()
    }
    
    @objc func dismisKey(){
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    func setUpView(){
        self.view.backgroundColor = myBackgroundColor

        self.view.addSubview(myTableView)
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(reportedButton)
        reportedButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(approvedButton)
        approvedButton.translatesAutoresizingMaskIntoConstraints = false
     
        
        
        topBar.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        logoutButton.topAnchor.constraint(equalTo: topBar.topAnchor).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor,constant: -10*iPhoneFactorX).isActive = true
        logoutButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        logoutButton.adjustDefaultButton(fontColor: "#FF6347", fontSize: 15, fontType: "2")
        logoutButton.setTitle("LOG OUT", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonAction), for: .touchUpInside)
        
        
        
        myTableView.fillHorizontally()
        myTableView.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        myTableView.register(HomeCV.self, forCellReuseIdentifier: "HomeCV")
        myTableView.showsVerticalScrollIndicator = false
        myTableView.showsHorizontalScrollIndicator = false
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.rowHeight = UITableView.automaticDimension
        myTableView.estimatedRowHeight = 10


        searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        myTableView.tableHeaderView = searchBar
        searchBar.addDoneOnKeyboardWithTarget(searchBar, action: #selector(dismisKey))

        topBar.title.text = "Issues"
        
        topBar.addSubview(reportIssueButton)
        reportIssueButton.translatesAutoresizingMaskIntoConstraints = false

        reportIssueButton.topAnchor.constraint(equalTo: topBar.topAnchor).isActive = true
        reportIssueButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor,constant: -10*iPhoneFactorX).isActive = true
        reportIssueButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        reportIssueButton.adjustDefaultButton(fontColor: "#FF6347", fontSize: 15, fontType: "2")
        reportIssueButton.setTitle("Logout", for: .normal)
        reportIssueButton.addTarget(self, action: #selector(reportIssueButtonAction), for: .touchUpInside)
        reportIssueButton.isHidden = true
        
        reportedButton.adjustDefaultButton(fontColor: "#000000", fontSize: 15, fontType: "2")
        reportedButton.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        reportedButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        reportedButton.trailingAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        reportedButton.heightAnchor.constraint(equalToConstant: 50*iPhoneFactorX).isActive = true
        reportedButton.addTarget(self, action: #selector(reportedButtonAction), for: .touchUpInside)
        reportedButton.setTitle("Reported", for: .normal)
        
        approvedButton.adjustDefaultButton(fontColor: "#000000", fontSize: 15, fontType: "2")
        approvedButton.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        approvedButton.leadingAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        approvedButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        approvedButton.heightAnchor.constraint(equalToConstant: 50*iPhoneFactorX).isActive = true
        approvedButton.addTarget(self, action: #selector(approvedButtonAction), for: .touchUpInside)
        approvedButton.setTitle("Resolved", for: .normal)
        reportedButton.isHidden = true
        approvedButton.isHidden = true
        
        reportedButton.sendActions(for: .touchUpInside)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        myTableView.addSubview(refreshControl) 
    }
    @objc func refresh() {
       fetchIssues()
    }

    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        filterData?.doctors = []
        filterData?.doctors = fetchedIssues?.doctors?.filter({ (doc) -> Bool in
            return (doc.speciality?.containsIgnoringCase(find: searchBar.text ?? "") ?? false)
            
        })
        myTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.filterData = self.fetchedIssues
        searchBar.endEditing(true)

        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count == 0){
            self.filterData = self.fetchedIssues
            
        }else{
            filterData?.doctors = []
            filterData?.doctors = fetchedIssues?.doctors?.filter({ (doc) -> Bool in
                return (doc.speciality?.containsIgnoringCase(find: searchBar.text ?? "") ?? false)
                
            })
        }
        myTableView.reloadData()

    }
    @objc func logoutButtonAction(){
        
        isloggedin = false
        token = ""
        
        UserDefaults.standard.set(false, forKey: "isloggedin")
        UserDefaults.standard.set("", forKey: "token")
        UserDefaults.standard.synchronize()
        
        let dest = LoginVC()
        self.navigationController?.pushViewController(dest, animated: true)
    }
    func fetchIssues(){
        API.callDictionaryAPI(webserviceFor: StringIdentifiers.getDoctors, webMethod: .get, parameters: [:]) { (error, task) in
            self.fetchedIssues = (task as? DoctorModel)
            self.filterData = self.fetchedIssues
            self.myTableView.reloadData()
            self.refreshControl.endRefreshing()
             
        }
    }
    
    @objc func reportedButtonAction(){
        selectButton(reportedButton)
        deselectButton(approvedButton)
    }
    @objc func approvedButtonAction(){
        selectButton(approvedButton)
        deselectButton(reportedButton)
    }
    
    func selectButton(_ sender : UIButton){
        sender.addBottomLine(withColor: myOrangeColor)
        currentButton = sender
        self.myTableView.reloadData()
    }
    func deselectButton( _ sender : UIButton){
        sender.addBottomLine(withColor: myBackgroundColor)
        self.myTableView.reloadData()

    }
    
    @objc func reportIssueButtonAction(){
        let dest = ReportVC()
        self.navigationController?.pushViewController(dest, animated: true)
        
    }
    
}
extension HomeVC : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData?.doctors?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCV", for: indexPath) as? HomeCV else {
            return UITableViewCell()
        }
             cell.setUpView(filterData?.doctors?[indexPath.row])
         
       
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
