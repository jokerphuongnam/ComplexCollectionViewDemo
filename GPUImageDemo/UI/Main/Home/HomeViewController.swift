//
//  HomeViewController.swift
//  GPUImageDemo
//
//  Created by pnam on 15/10/2022.
//

import UIKit
import Kingfisher

private enum HomeSection {
    case main(data: [String])
    case podcast(data: [String])
    case image(data: [String])
}

class HomeViewController: UIViewController {    
    @IBOutlet weak var collectionView: UICollectionView!
    private lazy var cache: [IndexPath] = []
    private lazy var data: [HomeSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: ImageCollectionViewCell.name, bundle: Bundle.main), forCellWithReuseIdentifier: ImageCollectionViewCell.name)
        collectionView.register(UINib(nibName: PodCastCollectionViewCell.name, bundle: Bundle.main), forCellWithReuseIdentifier: PodCastCollectionViewCell.name)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        setupData()
    }
    
    private func setupData() {
        data.append(.main(data: addNewData()))
        data.append(.podcast(data: addNewData()))
        var content = [String]()
        for _ in 0..<25 {
            content.append(contentsOf: addNewData())
        }
        data.append(.image(data: content))
        cache = []
    }
    
    private func addNewData() -> [String] {
        [
            "https://apod.nasa.gov/apod/image/2202/AuroraPillars_Correia_960.jpg",
            "https://cdn.huongnghiepaau.com/wp-content/uploads/2020/04/image-search-la-gi.jpg",
            "https://cdn.huongnghiepaau.com/wp-content/uploads/2020/04/image-meta-search.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/800px-Image_created_with_a_mobile_phone.png"
        ]
    }
    
    @objc private func loadData(_ refreshControl: UIRefreshControl) {
        setupData()
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
}

// MARK: - CollectionView Layout
private extension HomeViewController {
    private var layout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { (section, env) in
            switch section {
            case 0: fallthrough
            case 1: fallthrough
            case 2:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(300)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                group.interItemSpacing = .fixed(CGFloat(10))
                return section
            default: return nil
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch data[section] {
        case .main(data: let data):
            return data.count
        case .podcast(data: let data):
            return data.count
        case .image(data: let data):
            return data.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch data[indexPath.section] {
        case .main(data: let data):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.name, for: indexPath) as? ImageCollectionViewCell {
                if !cache.contains(indexPath), let imageURL = URL(string: data[indexPath.item]) {
                    cell.imageView.kf.setImage(with: imageURL, options: nil) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success:
                            self.cache.append(indexPath)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                cell.titleLabel.text = "\(indexPath.row)"
                return cell
            }
        case .podcast(data: let data):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PodCastCollectionViewCell.name, for: indexPath) as? PodCastCollectionViewCell {
                
                return cell
            }
        case .image(data: let data):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.name, for: indexPath) as? ImageCollectionViewCell {
                if !cache.contains(indexPath), let imageURL = URL(string: data[indexPath.item]) {
                    cell.imageView.kf.setImage(with: imageURL, options: nil) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success:
                            self.cache.append(indexPath)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                cell.titleLabel.text = "\(indexPath.row)"
                return cell
            }
        }
        fatalError()
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
}

extension HomeViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        for indexPath in indexPaths {
//            if !cache.contains(indexPath) {
//                if let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.name, for: indexPath) as? ImageCollectionViewCell {
//                    if cell.titleLabel.text == "Label" {
//                        if let imageURL = URL(string: data[indexPath.item]) {
//                            cell.imageView.kf.setImage(with: imageURL, options: nil) { [weak self] result in
//                                guard let self = self else { return }
//                                switch result {
//                                case .success:
//                                    collectionView.reloadItems(at: [indexPath])
//                                    self.cache.append(indexPath)
//                                case .failure(let error):
//                                    print(error)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
}
