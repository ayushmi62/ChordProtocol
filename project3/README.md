# Chord Protocol
COP5615 - Distributed Operating Systems Principles Project 3

The goal of this project is to implement the Chord protocol and a simple object access service to prove its usefulness using the actor model in Elixir.

## Group Information
* **Ayush Mittal** - *UF ID: 3777 8171*
* **Shivaditya Jatar** - *UF ID: 6203 9241*

## Contents of this file

Flow of Program, Prerequisites, Instruction Section, What is working, What is the largest network dealt with

## Flow of Program

There are 2 arguments to be passed:
* Input the number of nodes
* Input the number of requests

#### For Bonus Part

There are 3 arguments to be passed:
* Input the number of nodes
* Input the number of requests
* Input the number of nodes to be killed


## Prerequisites

#### Erlang OTP 21(10.0.1)
#### Elixir version 1.7.3

## Instruction section

##### To run the App

```elixir
(Before running, Goto project3 directory, where mix.exs is present)
$ cd project3
$ mix escript.build
$ escript project3 <No. of Nodes> <No. of Requests>
e.g. escript project3 100 4
SAMPLE O/P->
Node with key: 9A15F42D1C524C306EB91C3DF1216DB248A8F224 created
Node with key: 356A192B7913B04C54574D18C28D46E6395428AB created
.
.
Calculating number of hops............................................................................................................................................................................................................................................................

Average number of hops are: 2.37
```
Starts the app, passing in <No. of Nodes> and <No. of Requests> values. The console prints the average number of hops (node connections) that have to be traversed to deliever a message.

##### To run the App (Bonus Part)
```elixir
(Before running, Goto project3_bonus directory, where mix.exs is present)
$ cd project3_bonus
$ mix escript.build
$ escript project3_bonus <No. of Nodes> <No. of Requests> <No. of nodes to kill>
e.g. escript project3 100 4 10
SAMPLE O/P->
Node with key: 9A15F42D1C524C306EB91C3DF1216DB248A8F224 created
Node with key: 356A192B7913B04C54574D18C28D46E6395428AB created
.
.
Calculating number of hops............................................................................................................................................................................................................................................................

Number of nodes which were failed: 10
Average number of hops are: 2.52
```
Starts the app, passing in <No. of Nodes>,<No. of Requests> and <No. of nodes to kill> values. The console prints the average number of hops (node connections) that have to be traversed to deliever a message.


## What is working

* Any node in the network is able to find the correct location of the file key k in O(log N) time.
* We successfully implemented Chord APIs for network join and routing as described in the Chord protocol research paper.
* All the finger tables are updated correctly after node join, using the algorithm described in chord protocol research paper.
* A request will keep track of the count of hops traversed and send the count to master once key is found. Master will keep track of total requests processed and shutdown when all requests are processed.

##### For Bonus Part

* For the bonus part of the project, we have implemented a failure model, which takes the number of nodes to fail as input, and we have also discussed system resilience in our bonus-report as well.

* In conclusion, the goals of this project have been successfully met along with the bonus implementation.

## What is the largest Network dealt with

* We managed to create a Chord network of 8570 nodes.
* We were also able to create network of 8570+ nodes, but it took significant amount of time(more than 20 minutes). It was mainly because of the increase in stabilization and fixing of finger tables.
* As the number of total nodes increased in network, average number of Hops were increased.
