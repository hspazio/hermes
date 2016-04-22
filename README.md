# Hermes
Simple Publish-Subscribe Hub

### Feeds

* `GET /feeds` - list all feeds
* `POST /feeds` - create new feed
* `GET /feeds/:id` - show feed

### Subscriptions

* `GET /feeds/:feed_id/subscriptions` - list all subscriptions to a feed
* `POST /feeds/:feed_id/subscriptions` - subscribe to a feed
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

Temporary store messages for a period of time and allow fetching them if client was down and could not receive the callback
* `GET /feeds/:feed_id/messages?from=20160326123244&to=20160417122032`
* `GET /feeds/:feed_id/messages?status=error`
