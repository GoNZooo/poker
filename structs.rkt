#lang racket/base

(provide (struct-out pokee)
         (struct-out pokeresult))

(struct pokee (name url)
        #:transparent)

(struct pokeresult (name bytes-read duration)
        #:transparent)
