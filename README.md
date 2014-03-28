todo-azurewebsites
==================

Starter code for learning to customize Azure Website deployment with Kudu


Running the web side locally
fork this repository in github
clone the fork to a local github repository

```
cd to src/web
npm install
gulp run
```

Deploying the web side

at repository root
```
azure site create dbtodosample --git --gitusername dburtonaz
```



create deployment scripts for node
copy contents of the node deploy.cmd to primary deploy.cmd
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



