import Foundation


class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoader
    private weak var delegate: MovieQuizViewController?
    
    
    private var askedQuestions: [Int] = []
    
    init(moviesLoader: MoviesLoader, delegate: MovieQuizViewController) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    enum DataError: Error, LocalizedError {
        case NoMoviesError
        case NoMovieImage
        
        var errorDescription: String? {
            switch self {
            case .NoMoviesError:
                return "Failed to create movie list"
            case .NoMovieImage:
                return "Can`t load image of movie"
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.items.count == 0 {
                        self.delegate?.didFailToLoadData(with: DataError.NoMoviesError)
                        return
                    }
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
            
        }
    }
    private var movies: [MostPopularMovie] = []
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            
            movies.remove(at: index) // remove used movie from movies array
            
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.sync {
                    self.delegate?.didFailToLoadData(with: DataError.NoMovieImage)
                    return
                }
        }
            
            let rating = Double(movie.rating) ?? 0
            let newRating = getRandomRating(startRating: rating)
            
            let text = "Рейтинг этого фильма больше чем \(newRating)?"
            let correctAnswer = rating > newRating
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    private func getRandomRating(startRating: Double) -> Double {
        let delta: Double = startRating * 0.1
        let randomValueToAdd: Double = Double.random(in: delta / 2...delta)
        let shouldBeAdded: Bool = Bool.random()
        var newRating: Double = shouldBeAdded ? startRating + randomValueToAdd : startRating - randomValueToAdd
        newRating = round(newRating * 10) / 10
        
        return newRating
    }
}
