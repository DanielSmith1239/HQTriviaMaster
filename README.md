# HQTriviaMaster
A neat little macOS program to scan and answer HQ Trivia questions.

**Minimum macOS Version:** 10.12

## Setup
1. Install [Tesseract OCR](https://github.com/tesseract-ocr/tesseract/wiki) and [ImageMagick](https://www.imagemagick.org/script/download.php) (or in Terminal with `brew install tesseract imagemagick` or `sudo port install tesseract imagemagick`).  

    HQTriviaMaster will warn at startup if any of these files are missing.  
    > **Note:** This step may require System Integrity Protection to be disabled.
2. Install the pods. This can be done using [CocoaPod's Mac App](https://cocoapods.org/app).
    > **Note:** If using Terminal, make sure you `cd` into HQTriviaMaster's directory first.
3. Visit [Custom Search Engine](https://cse.google.com/cse/) to create a Custom Google Search Engine (CSE).  Record the API Key and Search Engine ID.
    
    You can obtain an API Key by visiting [this link](https://developers.google.com/custom-search/json-api/v1/overview).
    > **Note:** [Google Developers](https://developers.google.com/custom-search/docs/tutorial/introduction) provides an excellent tutorial on setting up a CSE and obtaining an API Key.
    > 
    > **Note:** You **MUST** activate your CSE after setting it up or HQTriviaMaster will not work.  A link will be given to you for activation.
4. Open HQTriviaMaster by opening `HQTriviaMaster.xcworkspace`.  It will have a **white** icon.
5. When running HQTriviaMaster for the first time, you will be prompted for the CSE API Key and Search Engine ID.  You can change these at anytime by pressing `⌘,` or going to `HQTriviaMaster > Preferences`.
    > **Note:** You can add as many API Keys as you'd like.  Simply click `Add Key` while editing CSE information within HQTriviaMaster.

## Usage
1. Open QuickTime or your favorite screen recording software and begin displaying your iPhone, iPad, or iPod Touch on screen.
2. Click on the "Define Boundary" button to highlight the area where questions will be appearing.
3. Click on the "Start Scanning" button.  HQTriviaMaster will automatically scan the defined boundary for any HQ Tivia questions.
4. Sit back, relax, and let the program answer the questions for you!

## FAQ
> HQTriviaMaster won't build!

Ensure that you've installed the Pods (Step 2 under `Setup`) and that you've opened the project properly (Setup 4 under `Setup`)

> The app isn't scanning any of the questions!

Tesseract is a finicky thing built about 30 years ago.  The best guidance is to make sure the boundary fully goes over the question and answers with some padding on all 4 sides.  You can also try increasing/decreasing the window size.

> I've defined a boundary and HQTriviaMaster is scanning the questions, but I'm not getting any results!

This means your CSE is returning no data to the app.  Please ensure your CSE is activated and that it is searching the web (you may need to add `https://www.google.com` under "Sites to Search").

> I'm getting results, but they're completely wrong or very innacurate!

The accuracy can depend on a number of things, including but not limited to: how HQ formats the question, the type of question, the sites you've included in your CSE for searching, and Tesseract's scan of the question.  HQTriviaMaster attempts to do its best at determining the type of question being asked, and formatting search strings based on that information.  We are currently working on better question analysis to further improve accuracy.

> I have some other feedback!

Please use the "Issue" tab above (or follow [this link](https://github.com/DanielSmith1239/HQTriviaMaster/issues/)) and submit your issue.  Always remember to include a copy of the **full** log Xcode prints to its console.  If the issue is UI related, please also include a screenshot or video of the issue.

**Note:** Your issue may already be present.  If that's the case, don't open another issue, but rather add your information to the already opened issue

## To Do
- [ ] Improve accuracy (only 80% success rate right now).
- [ ] Add a way to answer a large amount of questions at once to test the program's accuracy.

## Contributers
 [**Daniel Smith**](https://github.com/DanielSmith1239) (owner), [**Michael Schloss**](https://github.com/schlossm).
 
## License
 [MIT License](https://github.com/DanielSmith1239/HQTriviaMaster/blob/master/LICENSE)
