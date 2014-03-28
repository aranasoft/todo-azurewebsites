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

1. Make sure gulp is installed globally
    ````
    npm install -g gulp
    ```

1. Run the build  
    ```bash
    gulp run
    ```

1. If a browser did not open automatically open a browser to localhost:3000
1. After you have experimented with the functionality in the browser exit the gulp process with Ctrl-C

##Deploying the web side
1. Make sure your current working directory is the repository root
1. Create the WebSite on Azure

    ```bash
    azure site create YOUR_TODO_SITENAME --git --gitusername USERNAME_FOR_AZURE_DEPLOYMENT
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
5. Close the deploy.cmd from the nodescripts folder to avoid confusion


## Editing Kudu script for gulp build
1. Locate the :Deployment section in the script
2. Note the sections for
    1. KuduSync
    2. SelectNodeVersion
    3. Install npm packages
1. Move the 1. KuduSync block below the 3. Install npm packages block
    ```dos
    :Deployment
    echo Handling node.js deployment.
    
    :: 2. Select node version
    call :SelectNodeVersion
    
    :: 3. Install npm packages
    IF EXIST "%DEPLOYMENT_TARGET%\package.json" (
        pushd "%DEPLOYMENT_TARGET%"
        call :ExecuteCmd !NPM_CMD! install --production
        IF !ERRORLEVEL! NEQ 0 goto error
        popd
    )
    
    :: 1. KuduSync
    IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
        call :ExecuteCmd "%KUDU_SYNC_CMD%" -v 50 -f "%DEPLOYMENT_SOURCE%" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
        IF !ERRORLEVEL! NEQ 0 goto error
    )
    ```
1. Change the :: comment blocks to echo to help with diagnostic output
    
    ```dos
    :: 2. Select node version
    :: 3. Install npm packages
    :: 1. KuduSync
    ```
    
    should become
    
    ```dos 
    echo 1. Select node version
    echo 2. Install npm packages
    echo 3. KuduSync
    ```
1. wrap the Install npm packages block in a directory change
1. remove directory prefix on package.json check
1. remove inner pushd popd
1. remove --production from npm install

    ```dos
    pushd src\web
    echo 3. Install npm packages
    IF EXIST "package.json" (
      call :ExecuteCmd !NPM_CMD! install
      IF !ERRORLEVEL! NEQ 0 goto error
    )
    popd
    ```
    
    > This mirrors the npm install you did locally
1. Add a block to execute gulp locally this goes after the Install npm packages block
    ```dos
    )

    echo "Execute Gulp"
    IF EXIST "Gulpfile.js" (
      call .\node_modules\.bin\gulp
      IF !ERRORLEVEL! NEQ 0 goto error
    )
    
    popd
    ```

    > The equivalent to this locally would be running gulp from the command line. The difference being that you do not have permissions to install globally (npm install -g) on Azure. So, you need to run the local copy.

1. Whew, that is quite a few changes. Looks like a good time to commit changes

## Kudu sync gulp build output to Azure Websites
1. add \src\web\dist to the -f (from) parameter on the call to Kudu sync
    ```
    echo 5. KuduSync
    IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
      call :ExecuteCmd "%KUDU_SYNC_CMD%" -v 50 -f "%DEPLOYMENT_SOURCE%\src\web\dist" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
      IF !ERRORLEVEL! NEQ 0 goto error
    )
    ```

## Try your deployment changes locally
1. From the repository root run deploy.cmd
    ```dos
    .\deploy.cmd
    ```
    > .\deploy.cmd is the powershell version deploy works at the command prompt
1. Verify the gulp build
    1. Navigate up a directory from the repository root
    2. You should see an artfacts folder
    3. Verify the presence of the wwwroot folder and an index.html file inside it
        > There will also be some other folders in here. This is just a spot check

## Deploy to Azure
1. Return the working directory to the repository root
2. Commit your changes
    ```dos
    git add .
    git ci -m "add gulp build to azure deployment"
    git push azure master
    ```
    > This initial commit will be time consuming. All of the npm packages as well as bower packages need to be installed for the first time. This is a process similar to NuGet package restore. Subsequent deployments will take _significantly_ less time. It is also worth noting that if you are running on the free teir of Azure Websites, there are cpu limits. Depending on the complexity of your build process you may hit them.
1. Visit the website


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



