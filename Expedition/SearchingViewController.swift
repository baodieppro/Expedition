//
//  ViewController.swift
//  Expedition
//
//  Created by Zeqiel Golomb on 8/16/19.
//  Copyright © 2019-2020 The Morning Company All rights reserved.

import UIKit
import WebKit
import Foundation
import CoreData

class ViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var ActInd: UIActivityIndicatorView!

    var userAgentVar: String = "mobile" //User agent
    let credits: String = "zeqe golomb:ui designer;finbarr oconnell:programmer;jackson yan:programmer;julian wright:programmer" //Credits
    var searchEngine: String = "https://duckduckgo.com/" //Search engine initialization
    var components = URLComponents(string: "https://duckduckgo.com/") //search engine
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() { //Setup stuff
        super.viewDidLoad()
        
        var components = URLComponents(string: searchEngine)
        
        let url = URL(string: "https://duckduckgo.com/")
        
        let request = URLRequest(url: url!)
        
        components?.scheme = "https"
        components?.host = "duckduckgo.com"
        
        webView?.load(request)
        
        webView?.addSubview(ActInd)
        ActInd?.startAnimating()
        
        webView?.navigationDelegate = self
        ActInd?.hidesWhenStopped = true
        
        Code().work()
    }
    
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    func socialMedia(urlString: String) {
        let url = URL(string: urlString)

        let request = URLRequest(url: url!)
        print(request.url?.absoluteString as Any)

        webView?.load(request)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
         webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/5.2 Mobile/15E148 Expedition/604.1"
         ActInd?.startAnimating()
         
     }
     
     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
         
        ActInd?.stopAnimating()
        searchBar.text = webView.url?.absoluteString
        if (UserDefaults.standard.bool(forKey: "save_history")) {
            let historyElementToAdd = HistoryElement(context: PersistenceService.context)
            historyElementToAdd.url = searchBar.text
            historyElementToAdd.title = webView.title
            PersistenceService.saveContext()
            HistoryTableViewController().historyArray.append(historyElementToAdd)
            HistoryTableViewController().tableView.reloadData()
        }
     }
     
     func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
         
         ActInd?.stopAnimating()
         
     }
    
    func verifyUrl (urlString: String?) -> Bool { //tests for url
        let url: URL?
        if (urlString!.contains(" ")){
            return false
        } else if urlString!.hasPrefix("http://") {
            url = URL(string: urlString!)
        } else {
            url = URL(string: "http://" + urlString!)
        }
        if let url = url {
            if (urlString!.contains(".") && !(urlString!.hasPrefix(".")) && !(urlString!.hasSuffix("."))) {
                if (UIApplication.shared.canOpenURL(url)) {
                    return true
                }
            }
        }
            return false
    }
    
    func openUrl(urlString: String) {
        if (verifyUrl(urlString: urlString)) {
            
            var url = URL(string: urlString)
            if (urlString.starts(with: "http://") || urlString.starts(with: "https://")) {
                print(urlString)
            } else {
                url = URL(string: "http://\(urlString)")
            }
            
            //searchBar.text = url?.absoluteString;
            
            let request = URLRequest(url: url!)
            
            webView?.load(request)
        }
        else {
            let request = searchText(urlString: urlString)
            
            webView?.load(request)
        }
    }
    
    func openHistoryUrl(index: Int) {
        print(HistoryTableViewController().historyArray)
        
        let fetchRequest: NSFetchRequest<HistoryElement> = HistoryElement.fetchRequest()
        
        var historyArray = [HistoryElement]()
        
        do {
            historyArray = try PersistenceService.context.fetch(fetchRequest)
            let url = historyArray[index].url
            openUrl(urlString: url!)
        } catch {
            print("ERROR OCCURRED")
        }
    }
    
    
    func searchText(urlString: String) -> URLRequest { //creates the url for a query using duckduckgo
        let queryItemQuery = URLQueryItem(name: "q", value: urlString);
        
        components?.queryItems = [queryItemQuery]
        
        let request = URLRequest(url: (components?.url)!)
        
        return request
    }
    


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { //turns the users input into something that the search engine can use
        
        searchBar.resignFirstResponder()
        
        searchBar.text = searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        searchBar.text = searchBar.text!.lowercased()
        
        openUrl(urlString: searchBar.text!)
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        print("yes")
        
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            
        if let components = components {
            components.host
            components.query
            components.percentEncodedQuery
            
            print("query items")
            print(components.queryItems)

            if let queryItems = components.queryItems {
                for queryItem in queryItems {
                    if queryItem.name == "url" {
                        openUrl(urlString: queryItem.value!)
                    }
                }
            }
        }
        
        return true;
    }
    

    @IBAction func reloadSwipe(_ sender: Any) {
   
        webView.reload()
    
    }

    @IBAction func desktopSiteSwipe(_ sender: Any) {
        if userAgentVar == "mobile" {
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/5.2 Expedition/605.1.15"
            let userAgentVar: String = "desktop"
            print(userAgentVar)
            webView.reload()
        }
        
        if userAgentVar == "desktop" {
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/5.2 Mobile/15E148 Expedition/604.1"
            let userAgentVar: String = "mobile"
            print(userAgentVar)
            webView.reload()
        }
   
    
    }

// webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil) What's this for?
 
}


