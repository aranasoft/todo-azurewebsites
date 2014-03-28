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
    
    ```dos
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

## Introduce WebAPI project
1. Open the TodoSample.sln file in Visual Studio
1. Rebuild Solution to pull in the NuGet packages
1. Configure for camelCase JSON serialization 
    1. Open the App_Start\WebApiConfig.cs file
    1. remove comments from code setting up the JSON serializer settings
        
        ```csharp
        // Web API configuration and services
        var settings = GlobalConfiguration.Configuration.Formatters.JsonFormatter.SerializerSettings;
        settings.ContractResolver = new CamelCasePropertyNamesContractResolver();
        ```
1. Determine port number used by IISExpress for Api
    1. Right click on TodoSample.Api project
    2. Select Properties
    3. Select the Web tab on the left
    4. Note Project Url as _localhost:31008_
1. Configure client app to use Api instead of local service
    1. Remove the "TodoService" from web\app\js\app.coffee (lines 5-35)
    2. Remove comments from the Api "asTodoApi" and "TodoService" (lines 7-47 after delete in previous step)
1. Add reference to signalr/hubs script
    1. Open web\app\pages\index.html
    2. Remove comments from script tag including signalr/hubs
    
    ```html
    <script type="text/javascript" src="/js/vendor.js"></script>
    <script type="text/javascript" src="/signalr/hubs"></script>
    <script type="text/javascript" src="/js/app.js"></script>   
    ```
    > The order of these scrips is important. The signalR base libaries must be included before the hubs. The hubs must be included before the client code. 

1. Create Database
    1. Build
    2. Set TodoSample.Api as the startup project
    3. Open the Package Manager Console (Tools -> NuGet Package Manager -> Package Manager Console)
    4. In Package Manager Console, set default project to TodoSample.Data
    5. Run Migrations from the PM> prompt

        ```dos
        Update-Database
        ```

1. Test Client and WebAPI combined locally
    1. Start debugging with TodoSample.Api as the startup project
    2. \api\todos to the url localhost:3108/api/todos
        3. You should see an empty array
    1. Ensure the current directory is \src\web in the powershell window
    2. Start the web project with a proxy to IIS

        ```dos
        gulp run --proxy --proxyPort 31008
        ```
2. Add a few items to make sure it works
3. Stop the gulp server with Ctrl-C at the console
4. Stop debugging in Visual Studio
5. This seems like a good place to commit changes

## Integrate WebAPI project into deployment script
1. Ensure current working directory is the repository root
2. Create a scaffolding script for the WebAPI project
    ```dos
    azure site deploymentscript --aspWAP .\src\TodoSample.Api\TodoSample.Api.csproj -s .\src\TodoSample.sln -o apiscript
    ```
    > Select no at the prompt to overwrite the .deployment file
3. Open the deploy.cmd in the apiscript directory
4. Copy the items after the definition of Kudu Sync to the clipboard (lines 50-62)

    ```dos
    IF NOT DEFINED DEPLOYMENT_TEMP (
      SET DEPLOYMENT_TEMP=%temp%\___deployTemp%random%
      SET CLEAN_LOCAL_DEPLOYMENT_TEMP=true
    )
    
    IF DEFINED CLEAN_LOCAL_DEPLOYMENT_TEMP (
      IF EXIST "%DEPLOYMENT_TEMP%" rd /s /q "%DEPLOYMENT_TEMP%"
      mkdir "%DEPLOYMENT_TEMP%"
    )
    
    IF NOT DEFINED MSBUILD_PATH (
      SET MSBUILD_PATH=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\msbuild.exe
    )
    ```
1. Paste them in the deploy.cmd in the repository root after the definition of KuduSync and before goto Deployment
    ```
      :: Locally just running "kuduSync" would also work
      SET KUDU_SYNC_CMD=%appdata%\npm\kuduSync.cmd
    )
    
    IF NOT DEFINED DEPLOYMENT_TEMP (
      SET DEPLOYMENT_TEMP=%temp%\___deployTemp%random%
      SET CLEAN_LOCAL_DEPLOYMENT_TEMP=true
    )
    
    IF DEFINED CLEAN_LOCAL_DEPLOYMENT_TEMP (
      IF EXIST "%DEPLOYMENT_TEMP%" rd /s /q "%DEPLOYMENT_TEMP%"
      mkdir "%DEPLOYMENT_TEMP%"
    )
    
    IF NOT DEFINED MSBUILD_PATH (
      SET MSBUILD_PATH=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\msbuild.exe
    )
    
    goto Deployment
    ```
1. Note the Deployment commands in the :: Deployment area
    1. Restore NuGet packages will pull referenced packages from NuGet before the build
    2. Build to the temporary path with compile the project
    3. KuduSync will copy the compiled output to the target folder
1. Copy all 3 sections to the clipboard (lines 68-89)
2. Paste this in the deploy.cmd file in the repository root after :Deployment but before echo Handling 

    ```dos
    ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    :: Deployment
    :: ----------
    
    :Deployment
    
    echo Handling .NET Web Application deployment.

    :: 1. Restore NuGet packages
    IF /I "src\TodoSample.sln" NEQ "" (
      call :ExecuteCmd "%NUGET_EXE%" restore "%DEPLOYMENT_SOURCE%\src\TodoSample.sln"
      IF !ERRORLEVEL! NEQ 0 goto error
    )
    
    :: 2. Build to the temporary path
    IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
      call :ExecuteCmd "%MSBUILD_PATH%" "%DEPLOYMENT_SOURCE%\src\TodoSample.Api\TodoSample.Api.csproj" /nologo /verbosity:m /t:Build /t:pipelinePreDeployCopyAllFilesToOneFolder /p:_PackageTempDir="%DEPLOYMENT_TEMP%";AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release /p:SolutionDir="%DEPLOYMENT_SOURCE%\src\\" %SCM_BUILD_ARGS%
    ) ELSE (
      call :ExecuteCmd "%MSBUILD_PATH%" "%DEPLOYMENT_SOURCE%\src\TodoSample.Api\TodoSample.Api.csproj" /nologo /verbosity:m /t:Build /p:AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release /p:SolutionDir="%DEPLOYMENT_SOURCE%\src\\" %SCM_BUILD_ARGS%
    )
    
    IF !ERRORLEVEL! NEQ 0 goto error
    
    :: 3. KuduSync
    IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
      call :ExecuteCmd "%KUDU_SYNC_CMD%" -v 50 -f "%DEPLOYMENT_TEMP%" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
      IF !ERRORLEVEL! NEQ 0 goto error
    )

    echo Handling node.js deployment.
    ```

1. Update the commented numbers to echo and renumber for clean output

    ```dos
    :: 1. Restore NuGet packages
    :: 2. Build to the temporary path
    :: 3. KuduSync
    echo 2. Select node version
    ```

    change these lines to
    
    ```dos
    echo 1. Restore NuGet packages
    echo 2. Build to the temporary path
    echo 3. KuduSync
    echo 4. Select node version    
    ```
    > Yes there are more below select node version, you should update those too

1. Make sure NuGet is available for local build
    > This is an awful hack. The NUGET_EXE environment variable is not set up when running localy. We need to find the NuGet executeable and set the environment variable NUGET_EXE to point at it. Mine happens to be installed by Chocolatey, yours may be elseware. Just ensure that the version is 2.8 or greater
    1. Above goto Deployment after the definition of MSBUILD_PATH, add a line that ensures NUGET_EXE is available

        ```dos
        IF NOT DEFINED MSBUILD_PATH (
          SET MSBUILD_PATH=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\msbuild.exe
        )
        
        IF NOT DEFINED NUGET_EXE (
          SET NUGET_EXE=c:\Chocolatey\lib\NuGet.CommandLine.2.8.0\tools\nuget.exe
        )
        
        goto Deployment
        ```

## Azure Deployment
1. Create a SQL Database with a name of _todosample_ on Azure and obtain its connection string
    > Note that this shoud be in the same region as your WebSite
2. Visit the CONFIGURE tab of the Azure Website in the management portal
3. Add a connection string entry for _todosdb_ and set its value to the connection string from step 1 of Azure Deployment
    > What is awesome here is that this allows for your web.config to remain safe. It will only ever point at a local database. You do not have to expose your production secrets anywhere but on the portal (or configuration script if you prefer). This setting will override the value in the web.config at runtime.



api project
remove comments on notification
change storage connection strings
start web project without debugging
start console app with debugging



