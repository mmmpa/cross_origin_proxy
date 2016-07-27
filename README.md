# Proxy server to test Ajax with a server without `Access-Control-Allow-Origin`

## Exec

```
$ TARGET=http://you-want-to-ajax.server.com ALLOW=http://your-local-js.server.com rails s
```

## Notice

This server uses global hash instance to store your all cookies from you-want-to-ajax.server.com.

Only use as a local server.

## Usage

All requests and parameters are proxied to `TARGET`.