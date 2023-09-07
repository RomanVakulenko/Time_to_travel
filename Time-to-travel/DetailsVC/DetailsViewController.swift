//
//  DetailsViewController.swift
//  time-to-travel
//
//  Created by Roman Vakulenko on 04.08.2023.
//

import UIKit

final class DetailsViewController: UIViewController {

    // MARK: - Private properties
    private var viewModel: DetailsViewModelProtocol //protocolCoverage так надо делать??

    // MARK: - Subviews
    private lazy var ticketView: UIView = {
        let ticketView = UIView()
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        ticketView.layer.cornerRadius = 10
        ticketView.backgroundColor = .white
        return ticketView
    }()

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
        likes.addTarget(self, action: #selector(tapAtLike(_:)), for: .touchUpInside)
        return likes
    }()


    // MARK: - Init
    init(viewModel: DetailsViewModelProtocol) { //protocolCoverage так надо делать??
        self.viewModel = viewModel //тк этого св-ва нет в суперклассе, то инициализируем его до super
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        bindViewModel()
        setTicketInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Private methods
    private func setupView() {
        view.backgroundColor = Styles.lightGrayColor
        view.addSubview(ticketView)
        [startImage, finishImage, departureCity, arrivalCity, atDate, landingDate, price, likes].forEach { ticketView.addSubview($0) }
    }

    private func bindViewModel() {
        viewModel.closureChangeState = { state in
            switch state {
            case .none:
                break
            }
        }
    }

    private func setTicketInfo() {
        let formatter = DateFormatter() //когда будем писать сетевой слой - занести это в хелповую функцию
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")

        let model = viewModel.oneTicketModel

        departureCity.text = "\(model.city1)"
        arrivalCity.text = "\(model.city2)"
        atDate.text = "At \(formatter.string(from: model.departureDate))"
        landingDate.text = "At \(formatter.string(from: model.arrivalDate))"
        price.text = "Price: \(String(model.price)) rub"

        if model.isLike == true {
            likes.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            likes.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }

    private func setupConstraints(){
        NSLayoutConstraint.activate([
            ticketView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ticketView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            ticketView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            ticketView.heightAnchor.constraint(equalToConstant: 128),

            startImage.leadingAnchor.constraint(equalToSystemSpacingAfter: ticketView.leadingAnchor, multiplier: 2),
            startImage.topAnchor.constraint(equalToSystemSpacingBelow: ticketView.topAnchor, multiplier: 1),
            startImage.widthAnchor.constraint(equalToConstant: Constants.heartSize),
            startImage.heightAnchor.constraint(equalToConstant: Constants.heartSize),

            departureCity.leadingAnchor.constraint(equalTo: startImage.trailingAnchor, constant: 8),
            departureCity.bottomAnchor.constraint(equalTo: ticketView.topAnchor, constant: Constants.heartSize + 8),
            departureCity.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2 - 16 - Constants.heartSize - 8),

            finishImage.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: ((UIScreen.main.bounds.width/2) + 16)),
            finishImage.topAnchor.constraint(equalToSystemSpacingBelow: ticketView.topAnchor, multiplier: 1),
            finishImage.widthAnchor.constraint(equalToConstant: Constants.heartSize),
            finishImage.heightAnchor.constraint(equalToConstant: Constants.heartSize),

            arrivalCity.leadingAnchor.constraint(equalTo: finishImage.trailingAnchor, constant: 8),
            arrivalCity.bottomAnchor.constraint(equalTo: ticketView.topAnchor, constant: Constants.heartSize + 8),
            arrivalCity.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2 - 16 - Constants.heartSize - 8 - 16),

            atDate.leadingAnchor.constraint(equalToSystemSpacingAfter: ticketView.leadingAnchor, multiplier: 2),
            atDate.topAnchor.constraint(equalToSystemSpacingBelow: startImage.bottomAnchor, multiplier: 1),

            landingDate.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: ((UIScreen.main.bounds.width/2) + 16)),
            landingDate.topAnchor.constraint(equalToSystemSpacingBelow: finishImage.bottomAnchor, multiplier: 1),

            price.leadingAnchor.constraint(equalToSystemSpacingAfter: ticketView.leadingAnchor, multiplier: 2),
            price.topAnchor.constraint(equalToSystemSpacingBelow: atDate.bottomAnchor, multiplier: 2),

            likes.trailingAnchor.constraint(equalTo: ticketView.trailingAnchor, constant: -16),
            likes.bottomAnchor.constraint(equalTo: price.bottomAnchor)
        ])
    }

    // MARK: - Actions

    @objc func tapAtLike(_ sender: UIButton) {
        var model = viewModel.oneTicketModel

        if likes.imageView?.image == UIImage(systemName: "heart") {
            model.isLike = true ///меняем состояние лайка в модели
            likes.setImage(UIImage(systemName: "heart.fill"), for: .normal) /// на текущем устанавливаем heart.fill
        } else {
            model.isLike = false ///меняем состояние лайка в модели
            likes.setImage(UIImage(systemName: "heart"), for: .normal) /// на текущем устанавливаем heart
        }

        viewModel.didTapLikeButton()
    }

}


// MARK: - Constants
extension DetailsViewController {
    enum Constants {
        static let heartSize: CGFloat = 36
    }
}




