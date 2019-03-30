# Football Gather - Server Side

<p align="center">
    <a href="https://github.com/vapor/vapor"><img src="https://img.shields.io/badge/Vapor-3.3.0-blue.svg" alt="Vapor 3.3.0" /></a>
    <a href="https://swift.org"><img src="https://img.shields.io/badge/swift-5-orange.svg" alt="Swift 5" /></a>
    <a href="https://developer.apple.com/xcode/"><img src="https://img.shields.io/badge/Xcode-10.2-blue.svg" alt="Xcode 10.2" /></a>
</p>
                                                                                                                         
FootballGather is a demo project for friends to get together and play football matches as quick as possible.
My intention is to to try out different iOS Architecture Patterns and use server side Swift (Vapor this time).

This repo contains the server side logic. For the iOS version, please check <a href="https://github.com/radude89/footballgather-ios" target="_blank">Football Gather - iOS Side</a>.

* If you want to get started with Vapor, this video is awesome: <a href="https://www.raywenderlich.com/870225-server-side-swift-with-vapor">Server Side Swift with Vapor</a> from <a href="https://www.raywenderlich.com/">Ray Wenderlich</a>.
* <a href="https://github.com/vapor/vapor">Vapor Web Framework</a>
* <a href="https://docs.vapor.codes/3.0/">Vapor Docs</a>

## Features
* Ability to add players
* Set countdown timer for matches
* Use the application in offline mode
* Persist players

## TODOs

- [ ] Finish the implementation of the web services API
- [ ] Nice to have basic access authentication

## Database Structure

<p align="center">
    <img src="https://github.com/radude89/footballgather-ws/blob/master/Screenshots/FootballGather-db-diagram-v01.png" width="50%" height="50%" alt="FootballGather-db-diagram" />
</p>

## API

### UserController
* **POST** /api/users/login - Login functionality for users
* **POST** /api/users - Registers a new user
* **GET** /api/users - Get the list of users
* **DELETE** /api/users - Get the list of users

### PlayerController
* **GET /api/players** - Gets the list of players
* **GET /api/players/{playerId}** - Gets the player by its id
* **GET /api/players/{playerId}/gathers** - Gets the list of gathers for the player
* **POST /api/players** - Adds a new player
* **DELETE /api/players/{playerId}** - Deletes a player with a given id
* **PUT /api/players/{playerId}** - Updates a player by its id

### GatherController
* **GET /api/gathers** - Gets the list of gathers
* **GET /api/gathers/{gatherId}** - Gets the gather by its id
* **GET /api/gathers/{gatherId}/gathers** - Gets the list of players in the gather specified by id
* **POST /api/gathers** - Adds a new gather
* **DELETE /api/gathers/{gatherId}** - Deletes a gather with a given id
* **PUT /api/gathers/{gatherId}** - Updates a gather by its id

## Author
You can reach out to me <a href="https://twitter.com/radude89">@radude89 </a> or find me on <a href="https://stackoverflow.com/users/893046/radu-dan">Stack Overflow</a>.
