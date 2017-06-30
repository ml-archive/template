# Nodes Vapor Template
[![Swift Version](https://img.shields.io/badge/Swift-3.1-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-2-F6CBCA.svg)](http://vapor.codes)
[![Linux Build Status](https://img.shields.io/circleci/project/github/nodes-vapor/template.svg?label=Linux)](https://circleci.com/gh/nodes-vapor/template)
[![macOS Build Status](https://img.shields.io/travis/nodes-vapor/template.svg?label=macOS)](https://travis-ci.org/nodes-vapor/template)
[![codebeat badge](https://codebeat.co/badges/52c2f960-625c-4a63-ae63-52a24d747da1)](https://codebeat.co/projects/github-com-nodes-vapor-template)
[![codecov](https://codecov.io/gh/nodes-vapor/template/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/template)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/nodes-vapor/template)](http://clayallsopp.github.io/readme-score?url=https://github.com/nodes-vapor/template)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/template/master/LICENSE)

A basic, test-ready Vapor template.


## Getting started 🚀

This template has everything ready to go. Just create a new project using [Vapor toolbox](https://vapor.github.io/documentation/getting-started/install-toolbox.html).
```bash
vapor new MyApp --template=nodes-vapor/template
```


## Project layout 🗂

Due to the fact that `Droplet.run` is a blocking call and that XCTest has difficulty testing Applications, the project is split up into two modules: `App` and `AppLogic`. `App` contains the `main.swift` and is used for building the main executable. `AppLogic` is where all of your server's code will be and is the module used for tests. When you add a source file to your project *please* make sure it's a member of the `AppLogic` module.


## Xcode project  🔨 

[Vapor toolbox](https://vapor.github.io/documentation/getting-started/install-toolbox.html) makes it simple to generate a project for Xcode.
```bash
vapor xcode -y
```

### Starting your server  🏁 
In Xcode, select the `App`<sup>fig.1</sup> scheme if you want to startup your server.

![Image of App module](https://cloud.githubusercontent.com/assets/1977704/21701832/eb8c79f0-d35c-11e6-97c7-792f6a888a89.png)

### Testing your code ⏱
For testing, make sure to have the `NodesVaporApp`<sup>fig. 2</sup> selected.

![Image of NodesVaporApp module](https://cloud.githubusercontent.com/assets/1977704/21701830/e9975480-d35c-11e6-870e-e31e87240988.png)

Now, you can use `⌘U` like usual.

![Image of example test](https://cloud.githubusercontent.com/assets/1977704/21702082/4b8aaa10-d35e-11e6-9278-fb5c590751f6.png)


## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).
The package owner for this project is [Steffen](https://github.com/steffendsommer).


## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
