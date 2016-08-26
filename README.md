
# Proxy server to test Ajax with a server without `Access-Control-Allow-Origin`

## Exec

```
$ TARGET=http://you-want-to-ajax.server.com ALLOW=http://your-local-js.server.com rails s
```

## Usage

All requests, cookies and parameters are proxied to `TARGET`.
