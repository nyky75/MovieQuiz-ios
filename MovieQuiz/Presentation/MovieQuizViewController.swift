import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Private Properties
    private var correctAnswers = 0
    
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private lazy var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    private let dateFormatter = DateFormatter()
    private var moviesLoader: MoviesLoader = MoviesLoader()
    private let presenter = MovieQuizPresenter()
    // MARK: - @IBOutlet
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textView: UILabel!
    @IBOutlet private weak var counterView: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        
        questionFactory?.loadData()
        alertPresenter = AlertPresenterImpl(viewController: self)
    }
    // MARK: - Public methods
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
        showLoadingIndicator()
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        hideLoadingIndicator()
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textView.text = step.question
        counterView.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            showLoadingIndicator()
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    private func showAlert(quizResult quiz: QuizResultsViewModel) {
        let alertModel = AlertModel(title: quiz.title,
                                    text: quiz.text,
                                    buttonText: quiz.buttonText,
                                    buttonAction:
                                        {[weak self] in
            self?.presenter.resetQuestionIndex()
            self?.correctAnswers = 0
            self?.questionFactory?.requestNextQuestion()
        })
        
        alertPresenter?.show(AlertModel: alertModel)
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            showAlert(quizResult: QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: """
                Ваш результат: \(correctAnswers)/10
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.toString(dateFormatter: dateFormatter))
                Средняя точность: \(Int(statisticService.totalAccuracy))%
                """,
                buttonText: "Сыграть еще раз"))
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {activityIndicator.startAnimating() // включаем анимацию
        
    }
    private func hideLoadingIndicator() {
        
        activityIndicator.stopAnimating()
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let alertModel = AlertModel(title: "Ошибка",
                                    text: message,
                                    buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else {return}
            self.questionFactory?.loadData()
            
        }
        
        alertPresenter?.show(AlertModel: alertModel)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }}
