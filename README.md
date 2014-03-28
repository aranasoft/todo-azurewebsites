# todo-azurewebsites

This repository contains the code used to show how to manipulate deployment to Azure Websites and WebJobs. Topics covered include:

1. Performing gulp based builds for stand-alone client side components.
1. Integrating client side components to a WebAPI backend. SignalR used to notify clients of changes.
1. Adding a WebJob to peform background tasks and notify WebAPI of changes. 

Learning how to customize deployment using [Kudu](https://github.com/projectkudu/kudu) is the primary focus exercise. 

## What you will need
1. An active subscription to Azure
1. Visual Studio 2013 (possibly 2012, that is just untested)
1. Azure SDK 2.2
1. Node.js
1. Azure Cross-Platform tools
1. A text editor that understands opening a directory in the file system

## Getting Started
1. Fork this repository in github to your github account.
> Use that fork button in the upper right, it is really easy.

1. Clone the fork to a local github repository
    ```bash
    git clone git@github.com:MY_GITHUB_USERNAME/todo-azurewebsites.git
    ```

##Running the stand-alone client side web application locally

1. Install the build tools  

    ```bash
    cd src/web
    npm install
    ```

1. Run the build  
    ```bash
    gulp run
    ```


##Deploying the web side
1. Make sure your current working directory is the repository root
1. Create the WebSite on Azure

    ```bash
    azure site create dbtodosample --git --gitusername USERNAME_FOR_AZURE_DEPLOYMENT
    ```

1. Create a sample deployment script for a node project

    ```bash
    azure site deploymentscript --node -o nodescript
    ```

    > This will create a deploy.cmd in the nodescript folder that we will use as a template

1. Open the deploy.cmd file in the nodescripts folder
2. Copy its contents to the clipboard
3. Open the deploy.cmd at the repository root
4. Paste the clipboard contents
5. 
move kudusync to bottom
update echo  to be more useful
remove deployment target from check for package.json
pushd to \src\web\ before npm install
sync from \src/web/dist
push azure master

update app.js remove local service
uncomment api and service
uncomment signalr in index.html

web project
- uncomment contract resolver in webapiconfig
- show project properties for port

update database

\src\web gulp run --proxy --proxyPort 31008



api project
remove comments on notification
change storage connection strings
start web project without debugging
start console app with debugging



