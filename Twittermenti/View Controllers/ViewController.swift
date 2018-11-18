//
//  ViewController.swift
//  Twittermenti
//
//  Created by Kevin Wang on 11/15/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML


class ViewController: UIViewController {
    
    // MARK: - Constants
    struct Constants {
        static let TwitterAPIKey = "sfZRFV075gIi9J35TXE6QgbfM"
        static let TwitterAPISecretKey = "x4YBVfdSQ8nPCiYvCe1MgnE9WFbSxpnjhBGRcqbynLEUuXYr18"
        static let MaximumTweetPullCount = 100
    }
    
    // MARK: - Instance variables
    private let swifter = Swifter(consumerKey: Constants.TwitterAPIKey, consumerSecret: Constants.TwitterAPISecretKey)
    private let sentimentClassifier = TweetSentimentClassifier()
    
    
    // MARK: - Outlets
    @IBOutlet weak var sentimentLabel: UILabel!
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    @IBOutlet weak var predictButton: UIButton!
    // MARK: - Button Pressed Predict function
    
    @IBAction func predict(_ sender: Any) {
        
        guard let searchTerm = searchTextField.text else {
            return
        }
        
        fetchTweets(withSearchTerm: searchTerm)
    }
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - Fetch Tweet Methods
    
    private func fetchTweets(withSearchTerm : String) {
        searchTextField.resignFirstResponder()
        
        swifter.searchTweet(using: withSearchTerm, lang : "en", count : Constants.MaximumTweetPullCount, tweetMode : .extended, success: { (results, metadata) in
            
            var tweetTextArray : [TweetSentimentClassifierInput] = []
            
            for index in 0..<Constants.MaximumTweetPullCount {
                if let tweet = results[index]["full_text"].string {
                    tweetTextArray.append(TweetSentimentClassifierInput(text: tweet))
                }
            }
            
            self.makePredictions(withText: tweetTextArray)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Prediction Methods
    
    private func makePredictions(withText : [TweetSentimentClassifierInput]) {
        
        var currentScore = 0
        
        if let predictionResult = try? self.sentimentClassifier.predictions(inputs:withText).map{$0.label} {
            
            for prediction in predictionResult {
                
                if prediction == "Pos" {
                    currentScore += 1
                } else if prediction == "Neg" {
                    currentScore -= 1
                }
            }
            
            DispatchQueue.main.async {
                self.updateUIWith(prediction: currentScore)
            }
        }
    }
    
    // MARK: - UI Methods
    
    private func updateUIWith(prediction : Int) {
    
        
        if prediction > 20 {
            sentimentLabel.text = "😍"
        } else if prediction > 10 {
            sentimentLabel.text = "😀"
        } else if prediction > 5 {
            sentimentLabel.text = "🙂"
        } else if prediction < 5 {
            sentimentLabel.text = "🙁"
        } else if prediction < 10 {
            sentimentLabel.text = "😣"
        } else if prediction < 20 {
            sentimentLabel.text = "🤮"
        } else {
            sentimentLabel.text = "😐"
        }
        
        
    }
    
}

extension ViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("started")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("ended")
    }
    
}

