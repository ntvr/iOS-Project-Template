# iOS-Project-Template
Because current state of Xcode Project templates is not satisfying and this set of tools is not generic enough to be used as a framework, it needs to be copied into the project sources manually. 

It is meant to be adjusted within the project itself on per project basis.

## Installation
### Create new project
1. Start by creating new project using NTVR Single View Code project template.

### Clone sources
1. Navigate to your main source folder (most of the time shares the name with xcproj file).
2. Copy sources from this repository using following code:

```bash
# VARIABLES
PROJECT_TEMPLATE_FOLDER="iOS-Project-Template-unique-krhgkjangkngdl"

# CLONE AND TAKE
git clone --depth 1 --branch master https://github.com/ntvr/iOS-Project-Template.git $PROJECT_TEMPLATE_FOLDER
mv "$PROJECT_TEMPLATE_FOLDER/Utility" .
mv "$PROJECT_TEMPLATE_FOLDER/Persistence" .
mv "$PROJECT_TEMPLATE_FOLDER/Networking" .
mv "$PROJECT_TEMPLATE_FOLDER/Podfile" .
mv "$PROJECT_TEMPLATE_FOLDER/.gitignore" .

# CLEANUP CLONED PROJECT
rm -rf $PROJECT_TEMPLATE_FOLDER
```

3. Add newly cloned folders to your project from Xcode. Groups with associated folder should be created (yellow folders).
4. Reorganize added folders as you like. Suggested order though is Protocol > Generic use component > Data definition > Implementation. Also the dependent are always below  their dependency. For example LoginService (Protocol) > DefaultLoginRouter > DefaultLoginService.
5. Additional project setup, certificates, profiles, ...

