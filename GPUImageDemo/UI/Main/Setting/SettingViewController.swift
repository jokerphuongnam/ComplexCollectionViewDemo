//
//  SettingViewController.swift
//  GPUImageDemo
//
//  Created by pnam on 15/10/2022.
//

import UIKit
import CardSlider

class SettingViewController: UIViewController {
    @IBOutlet weak var infiniteScroll: InfinityScrollCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        infiniteScroll.dataSource = self
        infiniteScroll.layout = CustomLayout()
        infiniteScroll.collectionView.register(UINib(nibName: TextCollectionViewCell.name, bundle: Bundle.main), forCellWithReuseIdentifier: TextCollectionViewCell.name)
        let cardSliderViewController = CardSliderViewController.with(dataSource: self)
//        present(cardSliderViewController, animated: true)
    }
}

extension SettingViewController: CardSliderDataSource {
    func item(for index: Int) -> CardSliderItem {
        movies[index]
    }
    
    func numberOfItems() -> Int {
        movies.count
    }
}

// MARK: - CollectionView Layout
private extension SettingViewController {
    private var layout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { (section, env) in
            switch section {
            case 0: fallthrough
            case 1: fallthrough
            case 2:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.95))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                
                return section
            default: return nil
            }
        }
    }
}

extension SettingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = infiniteScroll.collectionView.dequeueReusableCell(withReuseIdentifier: TextCollectionViewCell.name, for: indexPath) as? TextCollectionViewCell {
            cell.title.text = "\(indexPath.item)"
            cell.title.textColor = .white
            if indexPath.item % 2 == 0 {
                cell.backgroundColor = .red
            } else {
                cell.backgroundColor = .blue
            }
            return cell
        }
        fatalError()
    }
}

final class CustomLayout: UICollectionViewLayout {
    private let size = UIScreen.main.bounds
    private lazy var contentSize: CGSize = {
        let cellWidth = contentWidth - 16 - 16 * 3
        let cellHeight = cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }()
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var selectedItem = 0 {
        didSet {
            invalidateLayout()
        }
    }
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.width
    }
    
    fileprivate var contentHeight: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth * CGFloat((collectionView?.numberOfItems(inSection: 0) ?? 0)), height: contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView else {
            return
        }
        let size = contentSize
        contentHeight = size.height
        let count = collectionView.numberOfItems(inSection: 0)
        for item in 0..<count {
            let indexPath = IndexPath(item: item, section: 0)
            let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            attributes.zIndex = count - item
            cache.append(attributes)
        }
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setContentOffset(CGPoint(x: contentWidth, y: 0), animated: false)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return [] }
        return (0..<4).map { index in
            let visibleIndex = selectedItem + index
            let visibleAttributes = cache[visibleIndex]
            let frame = visibleAttributes.frame
            let reveserIndex = 4 - index
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: visibleAttributes.indexPath)
            let contentOffsetX = CGFloat((Int(collectionView.contentOffset.x) % Int(contentWidth)))
            let calculateOffsetX = CGFloat(16 * reveserIndex)
            
            attributes.frame = CGRect(x: calculateOffsetX, y: 0, width: frame.width, height: frame.height)
            attributes.center = CGPoint(x: contentOffsetX + frame.width / 2, y: frame.height / 2)
            if selectedItem == visibleIndex {
                //                visibleAttributes.frame = visibleAttributes.frame.offsetBy()
            }
            print("\(attributes.frame)")
            attributes.transform = CGAffineTransform(scaleX: 1, y: (frame.height - CGFloat(reveserIndex * 16)) / frame.height)
            return attributes
        }
    }
}

private class CardsLayout: UICollectionViewLayout {
    public var itemSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    
    ///
    public var minScale: CGFloat = 0.8 {
        didSet { invalidateLayout() }
    }
    public var spacing: CGFloat = 35 {
        didSet { invalidateLayout() }
    }
    public var visibleItemsCount: Int = 3 {
        didSet { invalidateLayout() }
    }
    
    override open var collectionView: UICollectionView {
        return super.collectionView!
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    var itemsCount: CGFloat {
        return CGFloat(collectionView.numberOfItems(inSection: 0))
    }
    
    var collectionBounds: CGRect {
        return collectionView.bounds
    }
    
    var contentOffset: CGPoint {
        return collectionView.contentOffset
    }
    
    var currentPage: Int {
        return max(Int(contentOffset.x) / Int(collectionBounds.width), 0)
    }
    
    override open var collectionViewContentSize: CGSize {
        return CGSize(width: collectionBounds.width * itemsCount, height: collectionBounds.height)
    }
    
    private var didInitialSetup = false
    
    open override func prepare() {
        guard !didInitialSetup else { return }
        didInitialSetup = true
        
        let width = collectionBounds.width * 0.7
        let height = width / 0.6
        itemSize = CGSize(width: width, height: height)
        
        collectionView.setContentOffset(CGPoint(x: collectionViewContentSize.width - collectionBounds.width, y: 0), animated: false)
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        guard itemsCount > 0 else { return nil }
        
        let minVisibleIndex = max(currentPage - visibleItemsCount + 1, 0)
        let offset = CGFloat(Int(contentOffset.x) % Int(collectionBounds.width))
        let offsetProgress = CGFloat(offset) / collectionBounds.width
        let maxVisibleIndex = max(min(itemsCount - 1, currentPage + 1), minVisibleIndex)
        
        let attributes: [UICollectionViewLayoutAttributes] = (minVisibleIndex...maxVisibleIndex).map {
            let indexPath = IndexPath(item: $0, section: 0)
            return layoutAttributes(for: indexPath, currentPage, offset, offsetProgress)
        }
        attributes.forEach { attr in
            print(attr.frame)
        }
        return attributes
    }
    
    private func layoutAttributes(for indexPath: IndexPath, _ pageIndex: Int, _ offset: CGFloat, _ offsetProgress: CGFloat) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith:indexPath)
        let visibleIndex = max(indexPath.item - pageIndex + visibleItemsCount, 0)
        
        if visibleIndex == visibleItemsCount + 1 {
            //            delegate?.transition(between: indexPath.item, and: max(indexPath.item - 1, 0), progress: 1 - offsetProgress)
        }
        
        attributes.size = itemSize
        let topCardMidX = contentOffset.x + collectionBounds.width - itemSize.width / 2 - spacing / 2
        attributes.center = CGPoint(x: topCardMidX - spacing * CGFloat(visibleItemsCount - visibleIndex), y: collectionBounds.midY)
        attributes.zIndex = visibleIndex
        let scale = parallaxProgress(for: visibleIndex, offsetProgress, minScale)
        attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        //        let cell = collectionView.cellForItem(at: indexPath) as? ParallaxCardCell
        //        cell?.setZoom(progress: scale)
        //        let progress = parallaxProgress(for: visibleIndex, offsetProgress)
        //        cell?.setShadeOpacity(progress: progress)
        //
        //        switch visibleIndex {
        //        case visibleItemsCount + 1:
        //            attributes.center.x += collectionBounds.width - offset - spacing
        //            cell?.setShadeOpacity(progress: 1)
        //        default:
        //            attributes.center.x -= spacing * offsetProgress
        //        }
        
        return attributes
    }
    
    private func parallaxProgress(for visibleIndex: Int, _ offsetProgress: CGFloat, _ minimum: CGFloat = 0) -> CGFloat {
        let step = (1.0 - minimum) / CGFloat(visibleItemsCount)
        return 1.0 - CGFloat(visibleItemsCount - visibleIndex) * step - step * offsetProgress
    }
}

struct Movie: CardSliderItem {
    let image: UIImage
    let rating: Int?
    let title: String
    let subtitle: String?
    let description: String?
}

let movies = [
        Movie(image: #imageLiteral(resourceName: "9"), rating: 5, title: "Blade Runner 2049", subtitle: "2017", description: "A young blade runner's discovery of a long-buried secret leads him to track down former blade runner Rick Deckard, who's been missing for thirty years."),
        Movie(image: #imageLiteral(resourceName: "1"), rating: 3, title: "Back to the Future", subtitle: nil, description: nil),
        Movie(image: #imageLiteral(resourceName: "8"), rating: 2, title: "Ghostbusters", subtitle: "2016", description: "Physicists Abby Yates and Erin Gilbert are authors of a research book which posits the existence of paranormal phenomena, such as ghosts. While Abby continued to study the paranormal at a technical college with eccentric engineer Jillian Holtzmann, Erin, now a professor at Columbia University, disowned the work, fearing it will impact her tenure. When Abby republishes the book, Erin convinces her to agree to remove the book from publication in exchange by helping Abby and Jillian in a paranormal investigation. They witness a malevolent ghost, restoring Erin's belief in the paranormal, but video footage of the investigation is posted online, and Erin is fired by the university. She joins Abby and Jillian to set up new offices above a Chinese restaurant, calling themselves \"Conductors of the Metaphysical Examination\". They build equipment to study and capture ghosts, and hire the dimwitted but handsome Kevin Beckman as a receptionist."),
        Movie(image: #imageLiteral(resourceName: "2"), rating: 4, title: "Goodfellas", subtitle: "1990", description: "In 1955, Henry Hill, a high school student, becomes enamored of the criminal life in his neighborhood, and begins working for Paul \"Paulie\" Cicero and his associates: James \"Jimmy the Gent\" Conway, a truck hijacker; and Tommy DeVito, a fellow juvenile delinquent. Henry begins as fence for Jimmy, gradually working his way up to more serious crimes. Enjoying the perks of their criminal life, the three associates spend most of their nights at the Copacabana nightclub, carousing with women. Henry meets and later marries Karen Friedman, a Jewish woman from the Five Towns area of Long Island. Karen is initially troubled by Henry's criminal activities, but is soon seduced by his glamorous lifestyle.\n\nIn 1970, Billy Batts, a mobster in the Gambino crime family, repeatedly insults Tommy at a nightclub owned by Henry. Enraged, Tommy and Jimmy attack and kill him. Knowing their murder of a made man would mean retribution from the Gambinos, which could possibly include Paulie being ordered to kill them, Jimmy, Henry, and Tommy cover up the murder. They transport the body in the trunk of Henry's car, and bury it in upstate New York. Six months later, Jimmy learns that the burial site is slated for development, forcing them to exhume the decomposing corpse and move it.\n\nHenry decides to live with Janice, but Paulie insists he returns to Karen after completing a job for him. Henry and Jimmy are sent to collect a debt from a gambler in Tampa, but they are arrested after being turned in by the gambler's sister, a typist for the FBI. Jimmy and Henry receive ten-year prison sentences. In prison, Henry sells drugs smuggled in by Karen to support his family on the outside. In 1978, Henry is paroled, and expands his cocaine trade against Paulie's orders, soon involving Jimmy and Tommy. Jimmy organizes a crew to raid the Lufthansa vault at John F. Kennedy International Airport and take $6 million. After some of the crew buy expensive items in spite of Jimmy's orders and the getaway truck is found by police, he has most of the crew murdered. Tommy and Henry are spared from Jimmy's wrath, but Tommy is eventually killed by the Gambinos in retribution for Batts' murder, having been fooled into thinking he would become a made man.\n\nIn 1980, Henry has become a nervous wreck from cocaine use and insomnia. He tries to organize a drug deal with his associates in Pittsburgh, but he is arrested by narcotics agents, and jailed. After he is bailed out, Karen explains that she flushed $60,000 worth of cocaine down the toilet to prevent FBI agents from finding it during their raid, leaving the family virtually penniless. Feeling betrayed by Henry's drug dealing, Paulie gives him $3,200, and ends their association. Facing federal charges and realizing that Jimmy is planning to have him killed, Henry decides to enroll in the Witness Protection Program. He gives sufficient testimony to have Paulie and Jimmy arrested and convicted. Forced out of his gangster life, Henry now has to face living in the real world. He narrates \"I'm an average nobody. I get to live the rest of my life like a schnook\".\n\nThe end title cards reveal that Henry is still in the Witness Protection Program and in 1987, he was arrested in Seattle for narcotics conspiracy and he received five years probation. Since then, Henry has been clean. After 25 years of marriage, Henry and Karen separated in 1989. Paul Cicero died in 1988 in Fort Worth Federal Prison at the age of 73 due to respiratory illness. Jimmy Conway is serving a 20 years to life sentence in a New York prison for murder and that he would not be eligible for parole until 2004 when he would be 78 years old."),
        Movie(image: #imageLiteral(resourceName: "5"), rating: 5, title: "Pulp Fiction", subtitle: "1994", description: "Vincent Vega (John Travolta) and Jules Winnfield (Samuel L. Jackson) are hitmen with a penchant for philosophical discussions. In this ultra-hip, multi-strand crime movie, their storyline is interwoven with those of their boss, gangster Marsellus Wallace (Ving Rhames) ; his actress wife, Mia (Uma Thurman) ; struggling boxer Butch Coolidge (Bruce Willis) ; master fixer Winston Wolfe (Harvey Keitel) and a nervous pair of armed robbers, \"Pumpkin\" (Tim Roth) and \"Honey Bunny\" (Amanda Plummer)."),
        Movie(image: #imageLiteral(resourceName: "7"), rating: nil, title: "Fear and Loathing in Las Vegas", subtitle: "1998", description: "Raoul Duke (Johnny Depp) and his attorney Dr. Gonzo (Benicio Del Toro) drive a red convertible across the Mojave desert to Las Vegas with a suitcase full of drugs to cover a motorcycle race. As their consumption of drugs increases at an alarming rate, the stoned duo trash their hotel room and fear legal repercussions. Duke begins to drive back to L.A., but after an odd run-in with a cop (Gary Busey), he returns to Sin City and continues his wild drug binge."),
        Movie(image: #imageLiteral(resourceName: "6"), rating: 5, title: "The Big Lebowski", subtitle: "1998", description: "Jeff 'The Dude' Leboswki is mistaken for Jeffrey Lebowski, who is The Big Lebowski. Which explains why he's roughed up and has his precious rug peed on. In search of recompense, The Dude tracks down his namesake, who offers him a job. His wife has been kidnapped and he needs a reliable bagman. Aided and hindered by his pals Walter Sobchak, a Vietnam vet, and Donny, master of stupidity."),
]
