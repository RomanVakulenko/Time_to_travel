//
//  ViewController.swift
//  time-to-travel
//
//  Created by Roman Vakulenko on 04.08.2023.
//

// MVVM + C + (RxSwift/Combine)
// M - Model
// V - View
// VM - ViewModel

import UIKit

final class TicketsViewController: UIViewController {

    // MARK: - Private properties
    private let viewModel: TicketsViewModelProtocol // т.к. NetworkAPIProtocol тут не нужен

    // MARK: - Subviews
    private lazy var loadindView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = .white
        return view
    }()

    private let planeImage: UIImageView = {
        let plane = UIImageView(image: UIImage(systemName: "airplane.departure"))
        plane.image?.withTintColor(.systemBlue)
        plane.translatesAutoresizingMaskIntoConstraints = false

        return plane
    }()

    private let appTitle: UILabel = {
        let appLabel = UILabel()
        appLabel.set(color: .systemBlue, font: .boldSystemFont(ofSize: 24))
        appLabel.translatesAutoresizingMaskIntoConstraints = false
        appLabel.text = "Time to travel"
        return appLabel
    }()

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .systemBlue
        return spinner
    }()

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
//        layout.minimumLineSpacing = Constants.inset * 2 // удобно, когда 1 коллекция, чтобы не писать func в delegate
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = Styles.skyColor
        collectionView.register(AirTicketCollectionViewCell.self, forCellWithReuseIdentifier: AirTicketCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    // MARK: - Lifecycle
    init(viewModel: TicketsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        bindViewModel()
        viewModel.requestTickets()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }

    // MARK: - Private methods
    private func setupView() {
        view.backgroundColor = Styles.skyColor
        view.addSubview(collectionView)
        view.addSubview(loadindView)
        [planeImage, appTitle, spinner].forEach { loadindView.addSubview($0) }
    }

    private func bindViewModel() {
        viewModel.closureChangeState = { [weak self] state in /// здесь ловим state, который передает ViewModel кложурой
            guard let self else { return }

            switch state {/// обрабатываем происходящее на разных state
            case .none:
                ()

            case .loading:
                self.loadindView.isHidden = false
                self.spinner.startAnimating()
                self.title = ""

            case .loaded:
                self.loadindView.isHidden = true
                self.spinner.stopAnimating()

                self.title = "Авиабилеты"
                self.collectionView.reloadData()

            case .reloadItems(let indexPaths):
                collectionView.reloadItems(at: indexPaths)

            case .wrong(let alertTextForUser):
                DispatchQueue.main.async {
                    Alert.showToUser(atVC: self, errorDescriptionToUser: alertTextForUser)
                }
            }
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadindView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadindView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadindView.topAnchor.constraint(equalTo: view.topAnchor),
            loadindView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            spinner.bottomAnchor.constraint(equalTo: planeImage.topAnchor, constant: -16),
            spinner.centerXAnchor.constraint(equalTo: loadindView.centerXAnchor),

            planeImage.centerXAnchor.constraint(equalTo: loadindView.centerXAnchor),
            planeImage.centerYAnchor.constraint(equalTo: loadindView.centerYAnchor, constant: -40),
            planeImage.widthAnchor.constraint(equalToConstant: 170),
            planeImage.heightAnchor.constraint(equalToConstant: 128),

            appTitle.centerXAnchor.constraint(equalTo: loadindView.centerXAnchor),
            appTitle.topAnchor.constraint(equalTo: planeImage.bottomAnchor, constant: 16)
        ])
    }

}
// MARK: - UICollectionViewDataSource
extension TicketsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.ticketsListModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AirTicketCollectionViewCell.identifier,
            for: indexPath) as? AirTicketCollectionViewCell else {
            return UICollectionViewCell()
        }

        let model = viewModel.ticketsListModel[indexPath.item]
        cell.set(model: model)
        /// нажали лайк в ячейке и прокидываем его во viewModel, а она через координатор на 2ой экран
        cell.likeFromCellClosure = { [weak self] isLiked in
                self?.viewModel.updateLikeState(isLiked, at: indexPath)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didTapCell(at: indexPath) /// сообщаем viewModelи, что нажали на ячейку
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TicketsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: UIScreen.main.bounds.width - 32,
            height: 128
        )
    }
    /// отступы по периметру дисплея
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(
            top: Constants.inset,
            left: Constants.inset,
            bottom: Constants.inset,
            right: Constants.inset
        )
    }
    /// между рядами-строками для вертикальной коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.inset * 2
    }
}

// MARK: - Constants
extension TicketsViewController {
    enum Constants {
        static let inset: CGFloat = 8
    }
}
