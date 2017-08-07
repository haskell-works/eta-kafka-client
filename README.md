# Kafka bindings for ETA
[![CircleCI](https://circleci.com/gh/haskell-works/eta-kafka-client.svg?style=svg&circle-token=f2664b3602a45dedc11f48a3b9fa35753a91fa8e)](https://circleci.com/gh/haskell-works/eta-kafka-client)

## Example
An example can be found in the [example](example/Main.hs) project.

### Running the example
Running the example requires Kafka to be available at `localhost`.

#### Run Kafka inside `docker-compose`
If you already have Kafka accessible at `localhost:9092` skip this section.

```
$ export DOCKER_IP=your_ip_address
$ docker-compose up
```

**Note** `DOCKER_IP` should be a real IP address of your machine, not `127.0.0.1`.
The following script can be used as a helper (MacOS):
```
export DOCKER_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1)
```

#### Execute the example
```
$ etlas update
$ etlas install --dependencies-only
$ etlas run
"Running producer..."
"Running consumer..."
"one"
"two"
"three"
```
