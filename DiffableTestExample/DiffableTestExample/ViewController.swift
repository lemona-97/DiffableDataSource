//
//  ViewController.swift
//  DiffableTestExample
//
//  Created by wooseob on 2023/07/13.
//

import UIKit

struct CarBrand: Hashable {
    
    let id = UUID() // 객체를 구분하기 위해 넣음
    var brand: String
}

class ViewController: UIViewController {
    enum Section: CaseIterable {
        case main
    }
   
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    var brandArray = ["Laborghini", "Ferrari", "Maserati", "Hyundai", "Kia", "Tesla", "Benz", "BMW", "Audi", "Honda", "Ford", "Chevrolet", "Renault", "Laborghini", "Ferrari", "Maserati", "Hyundai", "Kia", "Tesla", "Benz", "BMW", "Audi", "Honda", "Ford", "Chevrolet", "Renault"]
    
    lazy var arr: [CarBrand] = {
        return self.brandArray.map { CarBrand(brand: $0)}
    }()
    
    var dataSource : UICollectionViewDiffableDataSource<Section, CarBrand>!
    
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        
        return isActive && isSearchBarHasText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myCollectionView.collectionViewLayout = self.createLayout()
        self.setupSearchController()
        self.setupDataSource()
        self.performQuery(with: nil)
        for _ in 0...100 {
            print(UUID())
        }
    }

    func createLayout() -> UICollectionViewCompositionalLayout {
        let spacing = CGFloat(10)
        let columns = 2
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(columns)), heightDimension: .absolute(30))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: columns)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        self.navigationItem.searchController?.searchResultsUpdater = self
        self.navigationItem.title = "Search Car Brand"
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupDataSource() {
        self.myCollectionView.register(CarBrandCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: myCollectionView, cellProvider: { collectionView, indexPath, carBrand in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CarBrandCollectionViewCell else { preconditionFailure() }
            cell.configure(text: carBrand.brand)
            return cell
        })
    }
    
    func performQuery(with filter: String?) {
        let filterd = self.arr.filter { carBrand in
            carBrand.brand.hasPrefix(filter ?? "")
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, CarBrand>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filterd)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        self.performQuery(with: text)
    }
}
