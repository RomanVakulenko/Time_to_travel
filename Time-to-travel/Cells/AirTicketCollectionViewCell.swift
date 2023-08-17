//
//  AirTicketCollectionViewCell.swift
//  time-to-travel
//
//  Created by Roman Vakulenko on 04.08.2023.
//

import UIKit

protocol AntiScrollLikeDelegate: AnyObject { ///1.0 нажали лайк в коллекции и чтобы он при скролле не "обнулился"
    func protectLikeState(at indexPath: IndexPath)
}

final class AirTicketCollectionViewCell: UICollectionViewCell {

    // MARK: - Public properties
    ///1.0 нажали лайк в коллекции и чтобы он при скролле не "обнулился"
    weak var delegateSavingLikeWhenScroll: AntiScrollLikeDelegate?
    // MARK: - Private properties
    ///1.0 нажали лайк в коллекции и чтобы он при скролле не "обнулился"
    private var currentIndexPath: IndexPath?

    //MARK: - Subviews
    private let startImage: UIImageView = {
        let startImage = UIImageView()
        startImage.image = UIImage(systemName: "airplane.departure")?.withTintColor(.systemBlue)
        startImage.translatesAutoresizingMaskIntoConstraints = false
        return startImage
    }()

    private let finishImage: UIImageView = {
        let finishImage = UIImageView()
        finishImage.image = UIImage(systemName: "airplane.arrival")?.withTintColor(.systemBlue)
        finishImage.translatesAutoresizingMaskIntoConstraints = false
        return finishImage
    }()

    private lazy var departureCity: UILabel = {
        let city = UILabel()
        city.translatesAutoresizingMaskIntoConstraints = false
        city.set(color: Styles.darkGrayColor, font: Styles.semiboldFont)
        return city
    }()

    private lazy var arrivalCity: UILabel = {
        let city = UILabel()
        city.translatesAutoresizingMaskIntoConstraints = false
        city.set(color: Styles.darkGrayColor, font: Styles.semiboldFont)
        return city
    }()

    private lazy var atDate: UILabel = {
        let date = UILabel()
        date.translatesAutoresizingMaskIntoConstraints = false
        date.set(color: Styles.mediumGrayColor, font: Styles.regularFont)
        return date
    }()

    private lazy var landingDate: UILabel = {
        let date = UILabel()
        date.translatesAutoresizingMaskIntoConstraints = false
        date.set(color: Styles.mediumGrayColor, font: Styles.regularFont)
        return date
    }()

    private lazy var price: UILabel = {
        let price = UILabel()
        price.translatesAutoresizingMaskIntoConstraints = false
        price.set(color: .black, font: Styles.littleFont)
        return price
    }()

    private lazy var likes: UIButton = {
        let likes = UIButton()
        likes.translatesAutoresizingMaskIntoConstraints = false
        likes.tintColor = .red
        likes.addTarget(self, action: #selector(tapAtLike), for: .touchUpInside)
        likes.isUserInteractionEnabled = true
        return likes
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

//    override func prepareForReuse() {
//        super.prepareForReuse() ///когда происходит binding с ViewModel или подписываемся на "Реактивщину" тогда заnilять, а иначе нет смысла, т.к. в методе cellForItemAt происходит set ячейки
//    }

    // MARK: - Public methods
    ///1.1 из коллекции пробрасываем IndexPath, чтобы   self.currentIndexPath = indexPath
    func set(model: [FlightTicket], at indexPath: IndexPath) {
        let formatter = DateFormatter() ///когда будем писать сетевой слой - занести это в хелповую функцию
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")

        let model = model[indexPath.item]

        departureCity.text = "\(model.city1)"
        arrivalCity.text = "\(model.city2)"
        atDate.text = "At \(formatter.string(from: model.departureDate))"
        landingDate.text = "At \(formatter.string(from: model.arrivalDate))"
        price.text = "Price: \(String(model.price)) $"
        
        if model.isLike == true {
            likes.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            likes.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        ///1.2 из коллекции пробрасываем IndexPath, чтобы передать его делегату
        self.currentIndexPath = indexPath
    }

    // MARK: - Private methods
    private func setupView(){
        [startImage, finishImage, departureCity, arrivalCity, atDate, landingDate, price, likes].forEach { contentView.addSubview($0) }
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = Styles.lightGrayColor
    }

    private func setupLayout(){
        NSLayoutConstraint.activate([
            startImage.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            startImage.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            startImage.widthAnchor.constraint(equalToConstant: Constants.heartSize),
            startImage.heightAnchor.constraint(equalToConstant: Constants.heartSize),

            departureCity.leadingAnchor.constraint(equalTo: startImage.trailingAnchor, constant: 8),
            departureCity.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.heartSize + 8),
            departureCity.widthAnchor.constraint(equalToConstant: contentView.frame.width/2 - 16 - Constants.heartSize - 8 - 8),

            finishImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ((contentView.frame.width/2) + 16)),
            finishImage.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            finishImage.widthAnchor.constraint(equalToConstant: Constants.heartSize),
            finishImage.heightAnchor.constraint(equalToConstant: Constants.heartSize),

            arrivalCity.leadingAnchor.constraint(equalTo: finishImage.trailingAnchor, constant: 8),
            arrivalCity.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.heartSize + 8),
            arrivalCity.widthAnchor.constraint(equalToConstant: contentView.frame.width/2 - 16 - Constants.heartSize - 8 - 16),

            atDate.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            atDate.topAnchor.constraint(equalToSystemSpacingBelow: startImage.bottomAnchor, multiplier: 1),

            landingDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ((contentView.frame.width/2) + 16)),
            landingDate.topAnchor.constraint(equalToSystemSpacingBelow: finishImage.bottomAnchor, multiplier: 1),

            price.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            price.topAnchor.constraint(equalToSystemSpacingBelow: atDate.bottomAnchor, multiplier: 2),

            likes.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            likes.bottomAnchor.constraint(equalTo: price.bottomAnchor)
        ])
    }


    // MARK: - Actions
    @objc func tapAtLike(_ sender: UIButton) {

//#error("как отсюда забрать состояние лайка и передать его в модель, чтобы при скролле лайк не терялся")
        if likes.currentImage == UIImage(systemName: "heart") {
            likes.setImage(UIImage(systemName: "heart.fill"), for: .normal)

        } else if likes.currentImage == UIImage(systemName: "heart.fill") {
            likes.setImage(UIImage(systemName: "heart"), for: .normal)
        }

        guard let indexPath = currentIndexPath else { return }
        ///1.3 делегату говорим, что изменилось состояние по indexPath
        delegateSavingLikeWhenScroll?.protectLikeState(at: indexPath)
    }
}

extension AirTicketCollectionViewCell {
    enum Constants {
        static let heartSize: CGFloat = 36
    }
}



