#lang racket/base

(provide (struct-out post))

(struct post (id tags title body date)
        #:transparent)
