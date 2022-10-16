//
//  CollectionViewCell+Extension.swift
//  GPUImageDemo
//
//  Created by pnam on 15/10/2022.
//

import UIKit

extension UICollectionViewCell {
    class var name: String {
        String(describing: Self.self)
    }
}
