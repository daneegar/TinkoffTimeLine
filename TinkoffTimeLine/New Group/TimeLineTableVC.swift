//
//  TimeLineTableVCTableViewController.swift
//  TinkoffTimeLine
//
//  Created by Denis Garifyanov on 06/01/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import UIKit
import CoreData
import Network

class TimeLineTableVC: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var listOfArticles: [Article] = [Article]()
    var currentQuanityOfArticles: Int?
    lazy var dataBase = DataBase(context: self.context)
    let monitor = NWPathMonitor()
    
    
    override func viewDidLoad() {
        setRefreshHandler()
        customizing()
        preLoader()
        super.viewDidLoad()
    }
    
    //MARK: - init
    func preLoader() {
        if readData() {
            tableView.reloadData()
        } else {
            let apiHandler = ApiHandler()
            apiHandler.getList(with: nil, and: nil) { (data, response, error) in
                guard let data = data else {return}
                self.updateTimeLineWithNews(with: data)
                self.setData()
            }
        }
    }
    
    func customizing() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 200
        tableView.prefetchDataSource = self
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected")
            }
        }
    }


    
    //MARK: - tableview Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfArticles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == listOfArticles.count - 1{
            let apiHandler = ApiHandler()
            apiHandler.getList(with: listOfArticles.count, and: 20) { (data, response, error) in
                if let data = data{
                    let indexes = self.indexPathsForInsert(fromIndex: self.listOfArticles.count, count: data.articles.count)
                    let newListOfArticles = data.articles.map {Article.init(fromResponse: $0, insertIntoManagesObjectContext: self.context)}
                    self.listOfArticles = self.listOfArticles + newListOfArticles
                    self.tableView.insertRows(at: indexes, with: .automatic)
                    self.setData()
                }
                if let error = error as? errors {
                    PopUpError.showAnAllert(type: error, sender: self)
                } else if let error = error {
                    print (error)
                }
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TheNewCell", for: indexPath) as! TheNewCell
        //TODO: - handle the error
        cell.comleteSelf(withArticle: listOfArticles[indexPath.row])
        return cell
    }
    
    //MARK: - update newsline methods
    func updateTimeLineWithNews (with response: Response) {
        var indexPaths: [IndexPath]
        guard let currentQuanity = self.currentQuanityOfArticles else {
            indexPaths = indexPathsForInsert(fromIndex: 0, count: response.articles.count)
            self.listOfArticles = response.articles.map {Article.init(fromResponse: $0, insertIntoManagesObjectContext: self.context)}
            self.tableView.insertRows(at: indexPaths, with: .automatic)
            self.currentQuanityOfArticles = response.total
            tableView.scrollToRow(at: indexPaths.first!, at: UITableView.ScrollPosition(rawValue: indexPaths.first!.row)!, animated: true)
            return
        }
        if currentQuanity < response.total {
            var quanityNewsToInsert = response.total - currentQuanity
            while quanityNewsToInsert != 0 {
                self.listOfArticles.insert(Article.init(fromResponse: response.articles[quanityNewsToInsert - 1], insertIntoManagesObjectContext: self.context), at: 0)
                quanityNewsToInsert -= 1
            }
            indexPaths = indexPathsForInsert(fromIndex: 0, count: quanityNewsToInsert)
            self.currentQuanityOfArticles = response.total
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func setCountOfArticle (indexPath: IndexPath)
    {
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.endUpdates()
        updateBase()
    }
    

    
    func indexPathsForInsert(fromIndex index: Int, count: Int) -> [IndexPath] {
        var resultIndexPath: [IndexPath] = []
        var i = count
        while i != 0 {
            let indexPath = IndexPath(row: i - 1 + index, section: 0)
            resultIndexPath.append(indexPath)
            i -= 1
        }
        return resultIndexPath
    }
}

//MARK: - prefetching methods
extension TimeLineTableVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

    }
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
    }
}
//MARK: - refresh handler
extension TimeLineTableVC {
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        let apiHandler = ApiHandler()
        apiHandler.getList(with: 0, and: 20) { (data, response, error) in
            if let data = data {
                self.updateTimeLineWithNews(with: data)
            }
            if let error = error as? errors {
                refreshControl.endRefreshing()
                PopUpError.showAnAllert(type: error, sender: self)
            } else if let error = error {
                print (error)
            }
            refreshControl.endRefreshing()
        }
        setData()
    }
    
    func setRefreshHandler(){
        tableView.refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
            refreshControl.tintColor = UIColor.yellow
            return refreshControl
        }()
        tableView.addSubview(self.refreshControl!)
    }
}


//MARK: - navigation methods
extension TimeLineTableVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toArticle" {
            let articleVC = segue.destination as! ArticleVC
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            articleVC.article = self.listOfArticles[(selectedIndexPath?.row)!]
            articleVC.indexPath = selectedIndexPath
            articleVC.mainView = self
            self.tableView.deselectRow(at: selectedIndexPath!, animated: true)
        }
    }
}

//MARK: - CoreData CRUD methods
extension TimeLineTableVC {
    func readData(wia request: NSFetchRequest<DataBase> = DataBase.fetchRequest()) -> Bool{
        do {
            let data = try context.fetch(request)
            if !data.isEmpty {
                dataBase = data.first!
                listOfArticles = Array((dataBase.listOfArticles)!) as! [Article]
                currentQuanityOfArticles = Int(dataBase.currentQuanityOfArticles)
                return true
            }
        } catch {
            PopUpError.showAnAllert(type: .reading, sender: self)
            return false
        }
        return false
    }
    
    func setData (){
        do{
            if clearBase() {
                let _ = self.listOfArticles.map {self.dataBase.addToListOfArticles($0)}
                self.dataBase.currentQuanityOfArticles = Int32(self.currentQuanityOfArticles!)
                try context.save()
            }
        } catch{
            PopUpError.showAnAllert(type: .saving, sender: self)
            print ("setting data error, \(error)")
        }
    }
    
    func clearBase () -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DataBase")
        fetchRequest.includesPropertyValues = false
        do {
            let items = try context.fetch(fetchRequest) as! [DataBase]
            for item in items {
                item.listOfArticles = []
            }
        } catch {
            PopUpError.showAnAllert(type: .saving, sender: self)
            print()
            return false
        }
    return true
    }
    
    func updateBase (){
        do {
            try context.save()
        }
        catch {
            PopUpError.showAnAllert(type: .saving, sender: self)
            print(error)
        }
    }
}
