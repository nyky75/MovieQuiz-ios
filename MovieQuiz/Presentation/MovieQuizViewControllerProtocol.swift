
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
       
    func showLoadingIndicator()
    func hideLoadingIndicator()
       
    func showNetworkError(message: String)
    func showFinalResults(alertModel: AlertModel)
    func enableButtons()
}
