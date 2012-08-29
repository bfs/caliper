# caliper

Server that takes a url, fetches the document and returns a map of elements and their measurements.

## setup

```
bundle install

#local testing

thin start
curl "http://localhost:3000/measure?url=http://www.google.com"

```
