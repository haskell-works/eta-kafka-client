# Kafka bindings for ETA
[![CircleCI](https://circleci.com/gh/haskell-works/eta-kafka-client.svg?style=svg&circle-token=f2664b3602a45dedc11f48a3b9fa35753a91fa8e)](https://circleci.com/gh/haskell-works/eta-kafka-client)

## Example
An example can be found in the [example](example/Main.hs) project.

### Running the example
Running the example requires Kafka/Zookeeper to be available at `localhost`.  

#### Run Kafka inside `docker-compose`
```
$ export DOCKER_IP=your_ip_address
$ docker-compose up
```

#### Add some data into the input topic
```
$ docker exec -it $(docker ps -aqf "ancestor=confluentinc/cp-kafka") bash
$ kafka-console-producer --broker-list localhost:9092 zookeeper --topic kafka-example-input
```
Add some line-by-line messages and exit the producer (`Ctrl+C`)</br>
Exit the container (`Ctrl+D`)

#### Execute the example
```
$ epm run
```
