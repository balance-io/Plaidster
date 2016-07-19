# Plaidster

## Features

- Authentication (Connect) including full MFA support
- Fetching a set of transactions using Connect
- Fetching a set of accounts using Connect
- Carthage Support
- More soon...

## Introduction
Plaid created a beautiful infrastructure that has been adopted by many of the largest financial applications that are being built around the world. They work hard to make interacting with money simple and intuitive, but iOS and OS X developers are still forced to write their own middleman between their app and Plaid's API. I spent weeks searching for the best *community-built* binding for iOS and unfortunately all of them were either incomplete or poorly designed. The other libraries were like tasting a lemon for the first time.

![gif](https://media.giphy.com/media/YrpYdQifOibzG/giphy.gif)

I ended up writing my own because I needed a decent API wrapper for a project I was hired to build. I started to pass this class around the other projects I was working on, but I decided to open source Plaidster so all you tired developers could instead crack a smile instead of the :grimacing: emoji.

![gif](https://media.giphy.com/media/TlK63Ezhvdo3MqWkges/giphy.gif)

## Features (Extended)
Plaidster is a work in progress. Plaidster will eventually support all of the endpoints and features that Plaid offers through all three of their API's (Auth, Connect and Balance). It is important that Plaidster has proper response and error handling and utilises the best native APIs for the job. 

What I'm working on:
- A thorough set of documentation
- A thorough unit testing suite
- Full support for all API endpoints
- Properly handling all possible client-side errors
- More soon...

## Contributing
Plaidster is under active development, and is currently used primarily by the upcoming OS X app [Balance](http://balancemy.money). If you're also searching for a good up-to-date Plaid binding for OS X or iOS, please consider contributing back to the project so we can achieve our goals easier, faster, and better. If you're interested in contributing and would like to know how you can help, please reach out. We're happy to merge in all reasonable pull requests. 

#### Find a problem?
Please file a new issue with a detailed description of the problem and steps to reproduce/sample code. If you're feeling really generous, submit a PR with tests that also fixes the problem. :smiley:

## Licensing
Plaidster has been published under the protection of the MIT License.
