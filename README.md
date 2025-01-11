# Football Gather - Server Side

<p align="center">
    <a href="https://github.com/vapor/vapor"><img src="https://img.shields.io/badge/Vapor-4-blue.svg" alt="Vapor 4" /></a>
    <a href="https://swift.org"><img src="https://img.shields.io/badge/swift-5.2-orange.svg" alt="Swift 5.2" /></a>
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

## Database Structure

<p align="center">
    <img src="https://github.com/radude89/footballgather-ws/blob/master/Screenshots/FootballGather-db-diagram-v04.png" width="50%" height="50%" alt="FootballGather-db-diagram" />
</p>

## API

### User Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/users` | Gets the list of users |
| `GET` | `/api/users/{userId}` | Gets the specified user by its id |
| `POST` | `/api/users` | Creates a new user |
| `POST` | `/api/users/login` | Logins a user and returns the token |
| `DELETE` | `/api/users` | Deletes the logged in user |

### Player Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/players` | Creates a new player |
| `DELETE` | `/api/players/{playerId}` | Deletes a player by its id |
| `PUT` | `/api/players/{playerId}` | Updates a player by its id |
| `GET` | `/api/players/{playerId}/gathers` | Gets the list of gathers for the player |
| `GET` | `/api/players` | Gets the list of players |

### Gather Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/gathers` | Gets the list of gathers |
| `POST` | `/api/gathers` | Creates a new gather |
| `DELETE` | `/api/gathers/{gatherId}` | Deletes a gather by its id |
| `PUT` | `/api/gathers/{gatherId}` | Updates a gather by its id |
| `POST` | `/api/gathers/{gatherId}/players/{playerId}` | Adds a player to a gather |
| `GET` | `/api/gathers/{gatherId}/players` | Gets the list of players in the gather |

## Author

You can reach out to me on my <a href="https://www.radude89.com/#home">website</a> or find me on GitHub <a href="https://github.com/radude89">radude89</a>.
