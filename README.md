# Nodes Vapor Template
[![Swift Version](https://img.shields.io/badge/Swift-3.1-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-2-F6CBCA.svg)](http://vapor.codes)
[![Linux Build Status](https://img.shields.io/circleci/project/github/nodes-vapor/template.svg?label=Linux)](https://circleci.com/gh/nodes-vapor/template)
[![macOS Build Status](https://img.shields.io/travis/nodes-vapor/template.svg?label=macOS)](https://travis-ci.org/nodes-vapor/template)
[![codebeat badge](https://codebeat.co/badges/52c2f960-625c-4a63-ae63-52a24d747da1)](https://codebeat.co/projects/github-com-nodes-vapor-template)
[![codecov](https://codecov.io/gh/nodes-vapor/template/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/template)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/nodes-vapor/template)](http://clayallsopp.github.io/readme-score?url=https://github.com/nodes-vapor/template)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/template/master/LICENSE)

A Vapor template for convenient and fast scaffolding 🏎


## 📦 Installation

This template has everything ready to go. Just create a new project using [Vapor toolbox](https://vapor.github.io/documentation/getting-started/install-toolbox.html).
```bash
vapor new MyApp --template=nodes-vapor/template
```


## Getting started 🚀

### Crypto

The two keys in `crypto.json` needs to be updated. You can use `openssl rand -base64 <length>` to generate random strings. You can use length 10 for the key in the `hash` object and you can use length 32 for the key in the `cipher` object.


### Environment variables

Before running your project, you need to make sure you have the following environment variables setup. For more information on how do this, have a look at our guide [here](https://github.com/nodes-vapor/readme/blob/master/Documentation/how-to-setup-environment-variables.md).

- `app.json`
    - `$PROJECT_NAME`: Name of your project (this will fallback to `my-project`).
    - `$PROJECT_URL`: Url for your project - there should most likely be one value per environment. This will fallback to `http://0.0.0.0:8080`.
- `bugsnag.json`
    - `$BUGSNAG_KEY`: API key for Bugsnag (this will fallback to '_').
- `mysql.json`
    - `$DATABASE_HOSTNAME`: Hostname for MySQL (this will fallback to `127.0.0.1`).
    - `$DATABASE_USER`: User for MySQL (this will fallback to `root`).
    - `$DATABASE_PASSWORD`: Password for MySQL (this will fallback to 'root').
    - `$DATABASE_DB`: Database name for project in MySQL (this will fallback to `my-project`).
- `redis.json`
    - `$REDIS_HOSTNAME`: Hostname for Redis (this will fallback to `127.0.0.1`).
    - `$REDIS_DATABASE`: Redis database.
    
Environment variables related to MySQL and Redis will be set automatically if you use e.g. Vapor Cloud. All other variables needs to be set manually, e.g. through the CLI tool. For more information, have a look at the official [Vapor Cloud docs](docs.vapor.cloud).


## Project layout 🗂

The project is split up into two modules: `Run` and `MyProject-Package`. `Run` contains the `main.swift` and is used for building the main executable. `MyProject-Package` is where all of your server's code will be and is the module used for tests. When you add a source file to your project *please* make sure it's a member of the `MyProject-Package` module.


## Xcode project  🔨 

[Vapor toolbox](https://vapor.github.io/documentation/getting-started/install-toolbox.html) makes it simple to generate a project for Xcode.
```bash
vapor xcode -y
```

### Starting your server  🏁 
In Xcode, select the `Run` scheme if you want to startup your server.


### Testing your code ⏱
For testing, make sure to have the `MyProject-Package` scheme selected. Then, you can use `⌘U` like usual.


## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).
The package owner for this project is [Steffen](https://github.com/steffendsommer).


## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
