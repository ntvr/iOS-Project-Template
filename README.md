# iOS Project Template
Because current state of Xcode Project templates is not satisfying and this set of tools is not generic enough to be used as a framework, it needs to be copied into the project sources manually. 

It is meant to be adjusted within the project itself on per project basis.

## Install Xcode templates
You can copy the templates manually into Xcode's template folder.

Or you can move them using this script:

```bash
TEMPLATE_DIR="$HOME/Library/Developer/Xcode/Templates"
FILE_TEMPLATE_DIR="$TEMPLATE_DIR/File Templates/Netvor/"
PROJECT_TEMPLATE_DIR="$TEMPLATE_DIR/Project Templates/Netvor/"

mkdir "$FILE_TEMPLATE_DIR" 2> /dev/null
cp -R XcodeFileTemplates/*.xctemplate "$FILE_TEMPLATE_DIR"

mkdir "$PROJECT_TEMPLATE_DIR" 2> /dev/null
cp -R XcodeProjectTemplates/*.xctemplate "$PROJECT_TEMPLATE_DIR"

```

## Create project
1. Start by creating new project using NTVR Single View Code project template.
3. Navigate into your main project folder (includes `xcodeproj` file).
3. Copy sources from this repository using following code:

```bash
# VARIABLES
PROJECT_TEMPLATE_FOLDER="iOS-Project-Template-unique-krhgkjangkngdl"
NEW_PROJECT_FILE=`ls | grep *.xcodeproj`
NEW_PROJECT_NAME=${NEW_PROJECT_FILE%".xcodeproj"}

# CLONE AND COPY
git clone --depth 1 --branch master https://github.com/ntvr/iOS-Project-Template.git $PROJECT_TEMPLATE_FOLDER
mv "$PROJECT_TEMPLATE_FOLDER/iOSProjectTemplate/Utility" $NEW_PROJECT_NAME
mv "$PROJECT_TEMPLATE_FOLDER/iOSProjectTemplate/Persistence" $NEW_PROJECT_NAME
mv "$PROJECT_TEMPLATE_FOLDER/iOSProjectTemplate/Networking" $NEW_PROJECT_NAME
mv "$PROJECT_TEMPLATE_FOLDER/Podfile" .
mv "$PROJECT_TEMPLATE_FOLDER/.swiftlint.yml" .
mv "$PROJECT_TEMPLATE_FOLDER/.gitignore" .

# REPLACE TARGET NAME IN PODFILE
sed  -i "" "s/iOSProjectTemplate/$NEW_PROJECT_NAME/g" Podfile

# CLEANUP CLONED PROJECT
rm -rf $PROJECT_TEMPLATE_FOLDER
```

4. Add newly cloned folders to your project from Xcode. Groups with associated folder should be created (yellow folders).
5. Reorganize added folders as you like. Suggested order though is Protocol > Generic use component > Data definition > Implementation. Also the dependent are always below  their dependency. For example LoginService (Protocol) > DefaultLoginRouter > DefaultLoginService.

## Enable SwiftLint
1. Add New Run Script Build phase with following code:

```bash
if which "${PODS_ROOT}/SwiftLint/swiftlint" > /dev/null; then
    # if you have project name with spaces or special characters
    swiftlint_cmd = "${PODS_ROOT}/SwiftLint/swiftlint"; "${swiftlint_cmd[@]}"
else
    echo "error: SwiftLint not installed, run `pod install`"
fi
```

## Setup project signing
1. For multiple configurations follow [guide](https://zeemee.engineering/how-to-set-up-multiple-schemes-configurations-in-xcode-for-your-react-native-ios-app-7da4b5237966)
2. Setup [HockeyApp](https://hockeyapp.net)/[Firebase](https://firebase.google.com)
3. Setup [Fastlane](https://fastlane.tools)
