//
//  AirTicketCollectionViewCell.swift
//  time-to-travel
//
//  Created by Roman Vakulenko on 04.08.2023.
//

import UIKit

final class AirTicketCollectionViewCell: UICollectionViewCell {

    // MARK: - Private properties
    var currentLikeState = false
    var likeFromCellClosure: ((Bool) -> Void)?

    // MARK: - Subviews
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

    private lazy var likeButton: UIButton = {
        let likes = UIButton()
        likes.translatesAutoresizingMaskIntoConstraints = false
        likes.tintColor = .red
        likes.addTarget(self, action: #selector(tapLikeInCollection), for: .touchUpInside)
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
    /// вызывается каждый раз при показе ячеек коллекции
    func set(model: TicketForUI) {
        departureCity.text = "\(model.city1)"
        arrivalCity.text = "\(model.city2)"
        atDate.text =   "At \(DateManager.createStringFromDate(model.departureDate, andFormatTo: "dd.MM.yyyy"))"
        landingDate.text = "At \(DateManager.createStringFromDate(model.arrivalDate, andFormatTo: "dd.MM.yyyy"))"
        price.text = "Price: \(String(model.price)) ₽"

        /// отрисовываем и актуализируем лайк, чтобы снимался корректно
        if model.isLike == true {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            currentLikeState = true
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            currentLikeState = false
        }
    }

    // MARK: - Private methods
    private func setupView() {
        [startImage, finishImage, departureCity, arrivalCity, atDate, landingDate, price, likeButton].forEach { contentView.addSubview($0) }
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = Styles.lightGrayColor
    }

    private func setupLayout() {
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

            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            likeButton.bottomAnchor.constraint(equalTo: price.bottomAnchor)
        ])
    }

    // MARK: - Actions
    @objc func tapLikeInCollection(_ button: UIButton) {
        currentLikeState.toggle()
        likeFromCellClosure?(currentLikeState) // передаем лайк во VC (он дальше - во viewModel)

        if currentLikeState == true {
            Animate.like(button)

        } else if currentLikeState == false {
            Animate.dislike(button)
        }
        print("Лайк ячейки коллекции стал \(currentLikeState)")

    }
}

extension AirTicketCollectionViewCell {
    enum Constants {
        static let heartSize: CGFloat = 36
    }
}
