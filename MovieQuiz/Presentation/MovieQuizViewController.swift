import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - @IBOutlet
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textView: UILabel!
    @IBOutlet private weak var counterView: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?
    private let dateFormatter = DateFormatter()
    private var moviesLoader: MoviesLoader = MoviesLoader()
    private var presenter: MovieQuizPresenter!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenterImpl(viewController: self)
        imageView.layer.cornerRadius = 20
        activityIndicator.hidesWhenStopped = true
    }

    // MARK: - Public functions
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textView.text = step.question
        counterView.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    func showNetworkError(message: String) {
        print("network error")
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка",
                                    text: message,
                                    buttonText: "Попробовать ещё раз") {
            [weak self] in
            guard let self = self else {return}
            self.presenter.restartGame()
        }
        alertPresenter?.show(AlertModel: alertModel)
    }

    func toggleYesNoButtons(toEnable: Bool) {
        yesButton.isEnabled = toEnable
        noButton.isEnabled = toEnable
    }
    
    func showFinalResults(alertModel: AlertModel) {
        alertPresenter?.show(AlertModel: alertModel)
    }
    
    // MARK: - IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
//        disableButtons()
        toggleYesNoButtons(toEnable: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
//        disableButtons()
        toggleYesNoButtons(toEnable: false)
    }
}
