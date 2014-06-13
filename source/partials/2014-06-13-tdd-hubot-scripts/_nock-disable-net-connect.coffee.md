```coffee
do nock.disableNetConnect
http.get 'http://google.com/'
# this code throw NetConnectNotAllowedError with message
# Nock: Not allow net connect for "google.com:80"

```
