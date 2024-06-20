import UIKit

class FavoritesCell: UICollectionViewCell {
    
    static let reuseID = "FavoritesCell"
    let bookCoverImageView = BookCoverImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(book: Book) {
        bookCoverImageView.downloadImage(from: book.image)
    }
    
    private func configure() {
        addSubview(bookCoverImageView)
        let padding: CGFloat = 8
        
        NSLayoutConstraint.activate([
            bookCoverImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            bookCoverImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            bookCoverImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            bookCoverImageView.heightAnchor.constraint(equalTo: bookCoverImageView.widthAnchor, multiplier: 1.5),
        ])
    }
}
