//
//  TimeLineTableVCTableViewController.swift
//  TinkoffTimeLine
//
//  Created by Denis Garifyanov on 06/01/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import UIKit

class TimeLineTableVC: UITableViewController {
    var listOfArticles: [Article] = [Article]()
    var currentQuanityOfArticles: Int?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
            refreshControl.tintColor = UIColor.red
            return refreshControl
        }()
        self.tableView.addSubview(self.refreshControl!)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
        self.tableView.prefetchDataSource = self
        let apiHandler = ApiHandler()
        apiHandler.getList(with: nil, and: nil) { (data, response, error) in
            guard let data = data else {return}
            self.updateTimeLineWithNews(with: data.articles, totalNews: data.total)
        }
    }
    
    //MARK: - tableview Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfArticles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TheNewCell", for: indexPath) as! TheNewCell
        //TODO: - handl the error
        cell.comliteSelf(withArticle: listOfArticles[indexPath.row])
        return cell
    }
    
    //MARK: - update newsline methods
    func updateTimeLineWithNews (with articles: [Article], totalNews: Int) {
        var indexPaths: [IndexPath]
        guard let currentQuanity = self.currentQuanityOfArticles else {
            indexPaths = indexPathsForInsert(fromIndex: 0, count: articles.count)
            self.listOfArticles = articles
            self.tableView.insertRows(at: indexPaths, with: .automatic)
            self.currentQuanityOfArticles = totalNews
            return
        }
        if currentQuanity < totalNews {
            var quanityNewsToInsert = totalNews - currentQuanity
            while quanityNewsToInsert != 0 {
                self.listOfArticles.insert(articles[quanityNewsToInsert - 1], at: 0)
                quanityNewsToInsert -= 1
            }
            indexPaths = indexPathsForInsert(fromIndex: 0, count: quanityNewsToInsert)
            self.currentQuanityOfArticles = totalNews
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        }
        
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
        let apiHandler = ApiHandler()
        if (indexPaths.last?.row)! >= listOfArticles.count - 3 {
            
            apiHandler.getList(with: listOfArticles.count, and: 20) { (data, response, error) in
                guard let data = data else { return }
                let indexes = self.indexPathsForInsert(fromIndex: self.listOfArticles.count, count: data.articles.count)
                self.listOfArticles = self.listOfArticles + data.articles
                self.tableView.insertRows(at: indexes, with: .automatic)
            }
        }
        
        apiHandler.getList(with: listOfArticles.count, and: 20) { (data, urlResponse, error) in
            
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        print(indexPaths)
    }
}

extension TimeLineTableVC {
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        let apiHandler = ApiHandler()
        apiHandler.getList(with: 0, and: 20) { (data, response, error) in
            guard let data = data else {
                refreshControl.endRefreshing()
                return
            }
            self.updateTimeLineWithNews(with: data.articles, totalNews: data.total)
            refreshControl.endRefreshing()
        }
        
    }
}
