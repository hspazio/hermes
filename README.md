# Hermes
Simple Sinatra Publish-Subscribe Hub

[![Code Climate](https://codeclimate.com/github/hspazio/hermes/badges/gpa.svg)](https://codeclimate.com/github/hspazio/hermes)
[![Test Coverage](https://codeclimate.com/github/hspazio/hermes/badges/coverage.svg)](https://codeclimate.com/github/hspazio/hermes/coverage)
[![Build Status](https://travis-ci.org/hspazio/hermes.svg?branch=master)](https://travis-ci.org/hspazio/hermes)

### Feeds

* `GET /feeds` - list all feeds
* `POST /feeds` - create new feed
```ruby 
{ name: 'my_awesome_topic' } 
```
* `GET /feeds/:id` - show feed

### Subscriptions

* `GET /feeds/:feed_id/subscriptions` - list all subscriptions to a feed
* `POST /feeds/:feed_id/subscriptions` - subscribe to a feed
```ruby
{ callback_url: 'https://myhost/callback/here' }
```
* `GET /subscriptions/:id` - show subscription
* `DELETE /subscriptions/:id` - unsubscribe from a feed
* `PATCH /subscriptions/:id` - update subscription (e.g. update :callback_url) 

### Messages

* `GET /feeds/:feed_id/messages` - list all messages posted to a feed
* `POST /feeds/:feed_id/messages` - post a message to a feed
* `GET /messages/:id` - show message

### Users
* `GET /users` - list all users
* `GET /users/:id` - show user

### Authentication
* `POST /login` 
```ruby 
{ username: 'hspazio', password: 'mySecret' }
```

## TODO
* Remove User from Message. User association for message is redundat because the User can only publish messages to the owned feeds.

Temporary store messages for a period of time and allow fetching them if client was down and could not receive the callback
* `GET /feeds/:feed_id/messages?from=20160326123244&to=20160417122032`
* `GET /feeds/:feed_id/messages?status=error`
