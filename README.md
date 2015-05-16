# Poker

I made this mostly to have something to compare the [go version](http://github.com/GoNZooo/gopoke) to.

## Differences?

### How to realize concurrency

Initially, I had thought to do it with [places](http://docs.racket-lang.org/reference/places.html?q=concurrency), but
while this assures complete parallell computation/execution, it's not actually comparable to what goroutines are.

With this in mind, one can choose between
[threads](http://docs.racket-lang.org/reference/threads.html?q=concurrency) or
[futures](http://docs.racket-lang.org/reference/futures.html?q=concurrency)
when doing stuff like this.

While threads do not actually execute completely in parallell, they are the most
lightweight choice as they do not create a huge enviroment in which they run (like places).

Futures are good, but ultimately are tricky to actually realize. As one can see in the documentation,
they can't actually guarantee that they will run things in parallell and one will usually have to
run the future analyzer and set up the problem solution to fit futures. Some problems simply can't use them
effectively.

With the above in mind I have chosen threads, as they will correspond roughly to goroutines,
as far as I can tell.

### Message passing / channels?

Racket does have channels, but even better than that, all threads have mail boxes that will allow
them to communicate. Because of this, I've chosen to replace the channels in the Go implementation
with message passing between the spawning threads and child threads.

In the end, all it means is that a child thread (for example, a `poke`) will take a parent thread descriptor
as an argument. It will then send the `pokeresult` to that thread via
[thread-send](http://docs.racket-lang.org/reference/threads.html?q=concurrency#%28part._threadmbox%29).

### sync.WaitGroup?

Obviously, there is no sync.WaitGroup in Racket. I have chosen to rely on
[thread-running](http://docs.racket-lang.org/reference/threads.html?q=concurrency#%28def._%28%28quote._~23~25kernel%29._thread-running~3f%29%29)
to know when all the pokes have been consumed from the channel or not.
