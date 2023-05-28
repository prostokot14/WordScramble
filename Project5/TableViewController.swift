//
//  TableViewController.swift
//  Project5
//
//  Created by Антон Кашников on 27.05.2023.
//

import UIKit

final class TableViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))

        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: .newlines)
            }
        }

        if allWords.isEmpty {
            allWords = ["silkwarm"]
        }

        startGame()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = usedWords[indexPath.row]
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = usedWords[indexPath.row]
        }

        return cell
    }

    private func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    private func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()

        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)

                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }

    private func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {
            return false
        }

        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }

        return true
    }

    private func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    private func isReal(word: String) -> Bool {
        let misspelledRange = UITextChecker().rangeOfMisspelledWord(in: word, range: NSRange(location: 0, length: word.utf16.count), startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }

    @objc private func promptForAnswer() {
        let alertController = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let submitAlertAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] _ in
            guard let answer = alertController?.textFields?[0].text else {
                return
            }
            self?.submit(answer)
        }

        alertController.addAction(submitAlertAction)
        present(alertController, animated: true)
    }
}
