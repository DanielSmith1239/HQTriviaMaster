# HQTriviaMaster

## Setup
1. Install [Tesseract OCR](https://github.com/tesseract-ocr/tesseract/wiki) and [ImageMagick](https://www.imagemagick.org/script/download.php) (or in Terminal with `brew install tesseract imagemagick`).  

    HQTriviaMaster will not start without these files present.  
    > **Note:** This step may require System Integrity Protection to be disabled.
2. Install the pods (in Terminal with `pod install`)
3. Visit [Custom Search Engine](https://cse.google.com/cse/) to create a Custom Google Search Engine (CSE).  Record the API Key and Search Engine ID.
4. When running HQTriviaMaster for the first time, you will be prompted for the CSE API Key and Search Engine ID.  You can change these at anytime by pressing `⌘,` or going to `HQTriviaMaster > Preferences`.

## Usage
1. Click on the "Define Boundary" button to set the boundry of where the question will be appearing.
2. Click on the "Start Scanning" button to begin scanning for questions.
3. Sit back, relax, and let the program answer the questions for you!

## To Do
- [ ] Improve accuracy (only 80% success rate right now).
- [ ] Add a way to answer a large amount of questions at once to test the program's accuracy.
- [x] Make the correct answer more obvious on the UI.
- [x] Let the user know when the program doesn't find any matches for all of the options.
- [x] Add the question type and accuracy to the UI.

## Contributers
 [**Daniel Smith**](https://github.com/DanielSmith1239) (owner), [**Michael Schloss**](https://github.com/schlossm).
 
 ## License
 [MIT License](https://github.com/DanielSmith1239/HQTriviaMaster/blob/master/LICENSE)
