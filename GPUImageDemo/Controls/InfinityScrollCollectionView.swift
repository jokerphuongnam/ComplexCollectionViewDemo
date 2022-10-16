//
//  InfinityScrollCollectionView.swift
//  GPUImageDemo
//
//  Created by pnam on 15/10/2022.
//

import UIKit

class InfinityScrollCollectionView: UIView {
    private var lastContentOffset: CGFloat = 0
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var layout: UICollectionViewLayout {
        get {
            collectionView.collectionViewLayout
        }
        set {
            collectionView.collectionViewLayout = newValue
        }
    }
    
    weak var dataSource: UICollectionViewDataSource?
    weak var delegate: UICollectionViewDelegate? {
        get {
            collectionView.delegate
        }
        set {
            collectionView.delegate = newValue
        }
    }
    
    var numberOfSets: Int = 3 {
        didSet {
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(row: numberOfSets, section: 0), at: .left, animated: false)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXibView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupXibView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.scrollToItem(at: IndexPath(row: numberOfSets, section: 0), at: .left, animated: false)
        super.layoutIfNeeded()
    }
    
    private func setupXibView() {
        Bundle.main.loadNibNamed(String(describing: Self.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupView()
    }
    
    private func setupView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension InfinityScrollCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = dataSource?.collectionView(collectionView, numberOfItemsInSection: section) else {
            return 0
        }
        return count + (2 * numberOfSets)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource else {
            return UICollectionViewCell()
        }
        let realCount = dataSource.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        var calculateIndex = (indexPath.row - numberOfSets) % realCount
        if calculateIndex < 0  {
            calculateIndex = realCount - abs(calculateIndex)
        }
        return dataSource.collectionView(collectionView, cellForItemAt: IndexPath(row: calculateIndex, section: indexPath.section))
    }
}

extension InfinityScrollCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let dataSource = dataSource else {
            return
        }
        let count = dataSource.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        if indexPath.row == numberOfSets - 1 {
            collectionView.scrollToItem(at: IndexPath(item: count + numberOfSets, section: 0), at: .left, animated: false)
        } else if indexPath.row == count + numberOfSets + 1 {
            collectionView.scrollToItem(at: IndexPath(item: numberOfSets, section: 0), at: .left, animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var indexPath: IndexPath? = nil
        if (lastContentOffset > scrollView.contentOffset.y) {
            indexPath = collectionView.indexPathsForVisibleItems.first
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            indexPath = collectionView.indexPathsForVisibleItems.last
        }
        guard let indexPath = indexPath, let dataSource = dataSource else {
            return
        }
        let count = dataSource.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        switch indexPath.row {
        case numberOfSets - 1:
            collectionView.scrollToItem(at: [0, count + numberOfSets - 1], at: .left, animated: false)
        case count + numberOfSets:
            collectionView.scrollToItem(at: [0, numberOfSets], at: .left, animated: false)
        default:
            break
        }
    }
}
