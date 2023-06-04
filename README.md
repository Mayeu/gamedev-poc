# Implementing a simple snake game with Elixir + Scenic

This repository contains an implementation of Snake using Elixir and the Scenic
framework.

The starting point is [this
article](https://medium.com/@giandr/elixir-scenic-snake-game-b8616b1d7ee0) in
which the author uses Scenic 0.10. I followed the steps but using Scenic 0.11
instead and added an agent storing the state of the game to support hot reload
of the game without losing the state (I also had many issues with it, so don't
consider it an example on how to do this.). You can find this implementation in
the `snake-scenic-0.11` folder.
