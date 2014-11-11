# todo-azurewebsites

This repository contains the code used to show how to manipulate deployment to Azure Websites and WebJobs. Topics covered include:

1. Performing `gulp` based builds for stand-alone client side components.
1. Integrating client side components to a WebAPI and SignalR backend.
1. Adding a WebJob to peform background tasks and notify WebAPI of changes.

Learning how to customize deployment using [Kudu](https://github.com/projectkudu/kudu) is the primary focus exercise.

## Prerequisites

1. An account on GitHub : [github.com](https://www.github.com)
1. An active Microsoft Azure subscription.

  > If you do not already have a subscription, sign up for a
  [free trial](http://azure.microsoft.com/pricing/free-trial/))

1. Microsoft Visual Studio 2012 or 2013

  > If you do not have Visual Studio, this workshop is compatible with
  [Visual Studio Express 2013 for Web](http://www.visualstudio.com/en-us/products/visual-studio-express-vs.aspx)
  \[[download](http://www.visualstudio.com/downloads/download-visual-studio-vs#d-express-web)\].

1. Azure SDK 2.4 : Download from [azure.microsoft.com/downloads](http://azure.microsoft.com/en-us/downloads/)

  > SDK for Visual Studio 2013 \[[Download](http://go.microsoft.com/fwlink/p/?linkid=323510&clcid=0x409)\]  
  > SDK for Visual Studio 2012 \[[Download](http://go.microsoft.com/fwlink/p/?linkid=323511&clcid=0x409)\]

1. Node.js : Install from [nodejs.org](http://www.nodejs.org)
1. A command-line Git source control client

  > We recommend GitHub for Windows \[[download](https://windows.github.com)\], though
  TortoiseGit \[[download](https://code.google.com/p/tortoisegit/)\] should also work.
  >
  > The Git functionality built in to Visual Studio is insufficient
  for this workshop.

1. A text editor that understands opening a directory in the file system

## Part 1: Introducing the Site

### Getting Started

1. Install the Azure Cross-Platform tools, a command-line toolkit that we will use to
   prepare our site for deployment.

  ```bash
  npm install azure-cli --global
  ```

1. Install `gulp`, a command-line task runner that we will use to
   prepare our JavaScript and CSS assets.

  ```bash
  npm install gulp --global
  ```

1. Fork this repository in github to your github account.

  > Use the fork button at the top right. It is really easy; don't fear the fork.

1. Clone the fork to a local github repository

  > The URL to Clone your fork is available on the right sidebar.
  ```bash
  git clone git@github.com:MY_GITHUB_USERNAME/todo-azurewebsites.git
  ```

### Connect to your Azure Account

1. From a command line, download your publication settings from your
   Azure account:

  ```bash
  azure account download
  ```

  > This will launch a Browser into Microsoft Azure, allowing you to
  > download your Azure Subscription's `.publishsettings` file. You may
  > need to sign in to your account if you haven't already done so.

1. Change your current directory to the path containing your
   `.publishsettings` file. This is usually in the `Downloads` folder.

  ```bash
  cd ~/Downloads
  ```

1. Import the `.publishsettings` file into your Azure tools.

  ```bash
  azure account import <MY_FILE_NAME>.publishsettings
  ```

### Run the stand-alone client-side web application

1. Open a command prompt and navigate into the root of your GitHub
   repository.
1. Install the build tools that have been pre-configured for this site

  ```bash
  cd src/web
  npm install
    ```

1. Run the build

  ```bash
  gulp run
  ```

1. A browser should open automatically for your site. If it did not, navigate to `http://localhost:3000`

1. Familiarize yourself with the site and its functionality. When you are finished, return to your command window, then exit the `gulp` process by entering `ctrl-c`.

## Part 2: Deplying the Web Site
### Your first Kudu Deployment Script

1. Make sure your current working directory is set to the root of your
   repository.

  > **Important:**  
  > If your current directory is still `src/web` from above, proceeding
  > to the next step will corrupt your local folder structure. Be sure
  > your current working directory matches the root of your repository.

1. Create the WebSite on Azure.

  > **Important:**  
  > The Git username for Azure deployment is a username you specify. It
  > is _not_ your GitHub username.

  ```bash
  azure site create <YOUR_TODO_SITENAME> --git --gitusername <USERNAME_FOR_AZURE_DEPLOYMENT>
  ```

  > You will be prompted to choose an Azure Data Center (location).
  > Choose a data center that is close to your current geographic
  > location.

1. Create a sample deployment script for a node project

  ```bash
  azure site deploymentscript --node -o nodescript
  ```

  > This will create `deploy.cmd` in the `nodescript` folder that we will use as a template

1. Open `deploy.cmd` file in the `nodescripts` folder
2. Copy its contents to the clipboard
3. Open the `deploy.cmd` file in the repository root
4. Paste the clipboard contents
5. Close the `deploy.cmd` from the `nodescripts` folder to avoid confusion


### Editing Kudu script for a gulp build

1. Locate the `:Deployment` section in the script.  
   Note the subsections for:

    1. KuduSync
    1. SelectNodeVersion
    1. Install npm packages

  > **What does each section do?**
  >
  > *KuduSync*  
  > This section directly synchronizes the code files from our Git
  repository with the code files in our `wwwroot`. However, our
  application has to do some preparatory work before it is ready to be
  moved into the `wwwroot` folder, so we will need to reorganize this
  list.
  >
  > *SelectNodeVersion*  
  > Azure Websites can run many different versions of node.js. This
  section is where Kudu detects the version of node our application
  uses so that every action is performed against the proper version
  >
  > *Install npm packages*  
  > Similar to a .NET application's NuGet packages, our node application
  has dependencies on other node packages. Here KuDu will restore
  those packages from the npm feed.

1. Move the `:: 1. KuduSync` block below the `:: 3. Install npm packages block`. KuduSync should be the last step in our deployment.

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

1. Change the `::` comment blocks to echo and renumber to help with diagnostic output.

  *Original code:*

  ```dos
  :: 2. Select node version
  :: 3. Install npm packages
  :: 1. KuduSync
  ```

  *Revised code:*

  ```dos
  echo 1. Select node version
  echo 2. Install npm packages
  echo 3. KuduSync
  ```

1. Wrap the `Install npm packages` block in a directory change.

  > Our `packages.json` file is in `src\web` rather than the repository root,
  so we will need to push into that directory. When we are finished
  with `packages.json`, we will need to perform `popd` to return to the
  previous directory.

  *Revised code:*

  ```dos
  pushd src\web
  echo 3. Install npm packages
  IF EXIST "%DEPLOYMENT_TARGET%\package.json" (
      pushd "%DEPLOYMENT_TARGET%"
      call :ExecuteCmd !NPM_CMD! install --production
      IF !ERRORLEVEL! NEQ 0 goto error
      popd
  )
  popd
  ```

1. Remove the directory prefix on the `package.json` check. Also, remove the
   `pushd` and `popd` that are inside of the `IF EXIST` block.

  > Because the current directory is already set to `src\web`, we can
  perform these actions from directly within this path.

  *Revised code:*

  ```dos
  pushd src\web
  echo 3. Install npm packages
  IF EXIST "package.json" (
    call :ExecuteCmd !NPM_CMD! install --production
    IF !ERRORLEVEL! NEQ 0 goto error
  )
  popd
  ```

  > This code now mirrors the `npm install` you did locally when first
  > getting started with the application.

1. Before the `popd` command above, add a block to execute `gulp`.

  > Be sure to add this after the `Install npm packages` section, but
  before its closing `popd` command.

  ```dos
  pushd src\web
  echo 3. Install npm packages
  IF EXIST "package.json" (
    call :ExecuteCmd !NPM_CMD! install --production
    IF !ERRORLEVEL! NEQ 0 goto error
  )

  echo 4. Execute Gulp
  IF EXIST "Gulpfile.js" (
      call .\node_modules\.bin\gulp build
      IF !ERRORLEVEL! NEQ 0 goto error
  )

  popd
  ```

  > The local equivalent to this block would be running `gulp` from the command
  line. However, your Azure account does not have permission to globally install
  (npm install -g) npm packages; this block will execute the application's local copy.

1. Whew. That is quite a few changes! Looks like a good time to `git commit` changes.


### Kudu sync gulp build output to Azure Websites

1. Add `\src\web\dist` to the `-f` (from) parameter on the call to Kudu sync.

  > Our `gulp` command prepares all site output and places it within
  > `src\web\dist`. This directory is equivalent to the `wwwroot`
  > content, so we will sync this to Azure's `wwwroot`.

  ```dos
  echo 5. KuduSync
  IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
      call :ExecuteCmd "%KUDU_SYNC_CMD%" -v 50 -f "%DEPLOYMENT_SOURCE%\src\web\dist" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
      IF !ERRORLEVEL! NEQ 0 goto error
  )
  ```


### Test your deployment changes locally

1. From your repository root, run `deploy.cmd`

  ```dos
  .\deploy.cmd
  ```

  > If you are running from a PowerShell command prompt, besure to include the `.cmd` extension.

1. Verify the `gulp` build
  1. Navigate up a directory from the repository root
  2. You should see an artfacts folder
  3. Verify the presence of the wwwroot folder and an index.html file inside it

  > There will be other folders in here; this is just a spot check.

### Deploy to Azure

1. Return the working directory to the repository root
2. Commit your changes

  ```dos
  git add .
  git commit -m "add gulp build to azure deployment"
  git push azure master
  ```

  > This initial commit will be time consuming. All of the npm and bower packages need
  to be installed for the first time. This is a process similar to NuGet package restore.
  Subsequent deployments will take _significantly_ less time. It is also worth noting that
  if you are running on the free tier of Azure Websites, there are CPU limits; depending on
  the complexity of your build process you may hit them.

1. Visit the website. Your project should be deployed.


## Part 3: Introducing the .NET Backend
### Bringing in WebAPI

1. Open the TodoSample.sln file in Visual Studio
1. Rebuild Solution to pull in the NuGet packages

### Configure JSON Serialization to use camelCase

1. Open the `App_Start\WebApiConfig.cs` file
1. Remove comments from code setting up the JSON serializer settings

  ```csharp
  // Web API configuration and services
  var settings = GlobalConfiguration.Configuration.Formatters.JsonFormatter.SerializerSettings;
  settings.ContractResolver = new CamelCasePropertyNamesContractResolver();
  ```

### Determine port number used by IISExpress for Api

1. Right click on TodoSample.Api project
2. Select Properties
3. Select the Web tab on the left
4. Note Project Url as _localhost:31008_


### Configure client app to use Api instead of local service

1. Remove the "TodoService" from web\app\js\app.coffee (lines 5-35)
1. Remove comments from the Api "asTodoApi" and "TodoService" (lines 7-47 after delete in previous step)

### Add reference to signalr/hubs script

1. Open web\app\pages\index.html
1. Remove comments from script tag including signalr/hubs

  ```html
  <script type="text/javascript" src="/js/vendor.js"></script>
  <script type="text/javascript" src="/signalr/hubs"></script>
  <script type="text/javascript" src="/js/app.js"></script>
  ```

  > The order of these scrips is important. The signalR base libaries
  (in `vendor.js`) must be included before the hubs. The hubs must be
  included before the client code (in `app.js`).

### Create Database

1. Compile the solution
1. Set TodoSample.Api as the startup project
1. Open the Package Manager Console (Tools -> NuGet Package Manager -> Package Manager Console)
1. In Package Manager Console, set default project to TodoSample.Data
1. Run Migrations from the PM> prompt

  ```dos
  Update-Database
  ```

### Test Client and WebAPI combined locally

1. Start debugging with `TodoSample.Api` as the startup project.
1. Add `\api\todos` to the url, yielding `localhost:31008/api/todos`. You should see an empty array.
1. Ensure the current directory is `\src\web` in the command prompt window
1. Start the web project with a proxy to IIS

  ```dos
  gulp run --proxy --proxyPort 31008
  ```

1. Add a few items to make sure it works
1. Stop the gulp server with Ctrl-C at the console
1. Stop debugging in Visual Studio
1. This seems like a good place to commit changes

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
2. Paste this in the deploy.cmd file in the repository root after :Deployment but before echo Handling node.js deployment

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
	> This actually introduces a bug with Kudu sync that is tricky to track down. Both Kudu sync commands are using the same manifest. Right now, the msbuild occurs first building into temp. Then Kudu sync copies from temp to the final destination. The gulp runs followed by Kudu sync syncronizing the final destination. We will fix this now by changing the order and some of the the destinations.

1. Move the Kudu sync command for the msbuild step after the Kudu sync command for the gulp build

	```dos
	popd

	echo 6. KuduSync
	IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
  	call :ExecuteCmd "%KUDU_SYNC_CMD%" -v 50 -f "%DEPLOYMENT_SOURCE%\src\web\dist" -t "%DEPLOYMENT_TARGET%" -n "%DEPLOYMENT_SOURCE%" -p "%u%" -i ".git;.hg;.deployment;deploy.cmd"
	  IF !ERRORLEVEL! NEQ 0 goto error
	)

	echo 7. KuduSync
	IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
	  call :ExecuteCmd "%KUDU_SYNC_CMD%" -v 50 -f "%DEPLOYMENT_TEMP%" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
	  IF !ERRORLEVEL! NEQ 0 goto error
	)
	```
1. Change the destination for the gulp build to DEPLOYMENT_TEMP
1. Change the manifest to %DEPLOYMENT_SOURCE%\src\web\generated\manifest to both the next and previous manifest on the gulp build Kudu sync

	```dos
	echo 6. KuduSync
	IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
	  call :ExecuteCmd "%KUDU_SYNC_CMD%" -v 50 -f "%DEPLOYMENT_SOURCE%\src\web\dist" -t "%DEPLOYMENT_TEMP%" -n "%DEPLOYMENT_SOURCE%\src\web\generated\manifest" -p "%DEPLOYMENT_SOURCE%\src\web\generated\manifest" -i ".git;.hg;.deployment;deploy.cmd"

	  IF !ERRORLEVEL! NEQ 0 goto error
	)
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
    echo 3. Select node version
    echo 4. Install npm packages
    ```

    > Yes there are more below install npm packages, you should update those too

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
1. Run a local deployment for testing
	1. Return working directory to repository root
	2. Run the deployment script

		```dos
		deploy.cmd
		```

## Azure Deployment
1. Create a SQL Database with a name of _todosample_ on Azure and obtain its connection string

    > Note that this shoud be in the same region as your WebSite

1. In Package Manager Console, run `update-database`, specifying the Azure connection string

    ```
    update-database -ConnectionString "<string>" -ConnectionProviderName "System.Data.SqlClient"
    ```

1. Visit the CONFIGURE tab of the Azure Website in the management portal
1. Add a connection string entry for _todosdb_ and set its value to the connection string used in step 2 of Azure Deployment

    > What is awesome here is that this allows for your web.config to remain safe. It will only ever point at a local database. You do not have to expose your production secrets anywhere but on the portal (or configuration script if you prefer). This setting will override the value in the web.config at runtime.

1. Commit your changes and push to Azure
1. Visit your WebSite and see your persisted changes now


## Update Api to send notifications to storage queue
1. Create a storage account in the management portal
2. Copy the management key to the clipboard
3. Update connection strings from Emulator connection string to live connection string

    > This requirement should go away with a future release of the storage emulator. As of this writing the storage emulator is behind what is actually deployed in Azure. The team working on the WebJobs SDK is using some of these features not yet available in the emulator. This is a known issue and will likely be addressed soon(ish).

    1. Update the web.config in the TodoSample.Api project

        ```xml
        <add name="storage" connectionString="DefaultEndpointsProtocol=https;AccountName=[accountname];AccountKey=[accesskey]"/>
        ```

    1. Update the app.config in the TodoSample.Processor project

        ```xml
        <add name="AzureJobsRuntime" connectionString="DefaultEndpointsProtocol=https;AccountName=[accountname];AccountKey=[accesskey]"/>
        <add name="AzureJobsData" connectionString="DefaultEndpointsProtocol=https;AccountName=[accountname];AccountKey=[accesskey]"/>
        ```

    > You may want to create two storage accounts one for local development and one for deployment. The connection strings will be overriden in the portal in a later step much like we did with the database connection string earlier.

1. Open the TodosController in the TodoSample.Api project
2. Remove the comments from the AddChangeNotification helper method

    ```csharp
    private void AddChangeNotification()
    {
        var queue = new EventQueue();
	    queue.AddNotification();
    }
    ```

## Testing locally
1. Set TodoSample.Api as the startup project
2. Start without debugging Ctrl-F5
1. Set TodoSample.Processor as the startup project
2. Start Debugging F5

    > You may only attach the debugger in Visual Studio to a single process. In this case we are choosing to attach to the TodoSample.Processor because it is the project we have not run yet. You could also start up the Processor from the command line as it is simply a console application. The choice is yours.

1. Start up the local proxy

    ```dos
    gulp run --proxy --proxyPort 31008
    ```

1. Validate new task items being created and in the console window the jobs being picked up from the queue.
1. Shut down the proxy and stop debugging in Visual Studio. You may also want to kill off the instance of IISExpress that was running the Api. 

# Including WebJob in the deployment script
1. Ensure current working directory is the repository root
1. Create a scaffolding script for the WebJobs project

	```dos
	azure site deploymentscript --dotNetConsole .\src\TodoSample.Processor\TodoSample.Processor.csproj -s .\src\TodoSample.sln -o webjobscript
	```

1. Open the deploy.cmd in the webjobscript directory
2. Inspect the Deployment section
	1. Note that the restore nuget is the same as what we have. Package restore is done at the solution level
	2. Note that the output path is different than our current msbuild process. This one builds to a sub-folder. That indicates to us that this msbuild needs to follow our existing one.
	2. Note the presence of the WEB_JOB_DEPLOY_CMD. At first glance, it would seem like something we need. What this command actually does is copy a HTML file into the website if only a WebJob is deployed. You can think if it as being similar to the hostingstart.html only this page will notify the visitor that the WebSite is running a WebJob
	3. The KuduSync is the same as our current sync for msbuild
	4. Shiny, not a lot to do this time.
1. Copy the msbuild step to the clipboard (lines 76-78)

	```dos
	:: 2. Build to the temporary path
	call :ExecuteCmd "%MSBUILD_PATH%" "%DEPLOYMENT_SOURCE%\src\TodoSample.Processor\TodoSample.Processor.csproj" /nologo /verbosity:m /t:Build /p:Configuration=Release;OutputPath="%DEPLOYMENT_TEMP%\app_data\jobs\continuous\deployedJob" /p:SolutionDir="%DEPLOYMENT_SOURCE%\src\\" %SCM_BUILD_ARGS%
	IF !ERRORLEVEL! NEQ 0 goto error
	```

1. Open the deploy.cmd in the repository root
2. Paste this msbuild step after step 2 and before step 3
3. Change the comments to echo and renumber for diagnostics. (If you are lazy like me you can use 2a instead of renumbering)

	```dos
	  call :ExecuteCmd "%MSBUILD_PATH%" "%DEPLOYMENT_SOURCE%\src\TodoSample.Api\TodoSample.Api.csproj" /nologo /verbosity:m /t:Build /p:AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release /p:SolutionDir="%DEPLOYMENT_SOURCE%\src\\" %SCM_BUILD_ARGS%
	)

	IF !ERRORLEVEL! NEQ 0 goto error

	echo 2a. Build to the temporary path
	call :ExecuteCmd "%MSBUILD_PATH%" "%DEPLOYMENT_SOURCE%\src\TodoSample.Processor\TodoSample.Processor.csproj" /nologo /verbosity:m /t:Build /p:Configuration=Release;OutputPath="%DEPLOYMENT_TEMP%\app_data\jobs\continuous\deployedJob" /p:SolutionDir="%DEPLOYMENT_SOURCE%\src\\" %SCM_BUILD_ARGS%
	IF !ERRORLEVEL! NEQ 0 goto error

	echo Handling node.js deployment.

	```

1. Perform a local deployment

	```dos
	deploy.cmd
	```

2. Note the copying of app_data in the output. That is our new WebJob
3. Commit your changes
4. Push to Azure
5. Visit the WebJobs tab under your Website on the portal
6. Sit back and think about how cool this really is

