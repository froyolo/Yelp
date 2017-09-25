//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, FiltersViewControllerDelegate {
    
    @IBOutlet weak var filtersButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    let defaultSearchTerm = "Restaurants"
    var businesses: [Business]! = [Business]()
    var searchBar: UISearchBar!
    var isMoreDataLoading = false // infinite scrolling
    var loadingMoreView:InfiniteScrollActivityView?
    var searchTerm: String!
    var resultsLimit = 20
    var offset = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
 
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        // Create the search bar programatically since it can't be dragged onto the nav bar
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = "Restaurants"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        // Set up default search term
        searchTerm = defaultSearchTerm
        
        // Get businesses
        doSearch(filters:[:])
    }
    
    // For infinite scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()

                // Load more results ...
                doSearch(filters:[:])
                
            }
            
            
        }
    }
    
    fileprivate func doSearch(filters: [String : AnyObject]) {
        
        // Not getting more data, so we reset the businesses to make sure we don't append
        if (!isMoreDataLoading) {
            businesses = [Business]()
            offset = 0
        } else {
            offset = businesses.count + 1
        }
        
        let categories = filters["categories"] as? [String] ?? nil
        let deals = filters["deals"] as? Bool
        
        var sort: YelpSortMode?
        if let sortFilter = filters["sort"] {
            sort = YelpSortMode(rawValue: sortFilter as! Int)
        }
        let distance = filters["distance"] as? NSNumber ?? nil
        
        // Perform request to Yelp API to get the list of businesses
        Business.searchWithTerm(term: searchTerm, sort: sort, categories: categories, deals: deals, distance: distance, limit: resultsLimit, offset: offset) { (businesses:[Business]?, error: Error?) in
            
            if businesses!.count > 0 {
                // Add businesses to existing
                for business in businesses!     {
                    self.businesses.append(business)
                }
            }
            // Update flag
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            
    
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
	        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilters" {
            let navigationController = segue.destination as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
        
            // Set self to be delegate of that filters VC
            filtersViewController.delegate = self
        } else if segue.identifier == "showDetail" {
            let detailViewController = segue.destination as! BusinessDetailViewController
            
            var indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            let business = businesses[indexPath.row]
            detailViewController.business = business
        }
     }
    
    func filtersViewController(filtersViewControllers: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        // Search within "Restaurants" so make sure the default search term is included if it isn't
        searchTerm = searchBar.text ?? defaultSearchTerm
        if searchBar.text?.range(of:defaultSearchTerm) == nil {
            searchTerm.append(" \(defaultSearchTerm)")
        }
        
        // Refresh results
        doSearch(filters: filters)
        
    }
    
}

// SearchBar methods
extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()

        // Clear out previous search and refresh
        searchTerm = defaultSearchTerm
        doSearch(filters:[:])
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        // Search within "Restaurants" so make sure the default search term is included if it isn't
        searchTerm = searchBar.text ?? defaultSearchTerm
        if searchBar.text?.range(of:defaultSearchTerm) == nil {
            searchTerm.append(" \(defaultSearchTerm)")
        }
        doSearch(filters:[:])
    }
}
