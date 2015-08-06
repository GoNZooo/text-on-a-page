#lang racket/base

(require racket/contract
         racket/cmdline

         "../db-interaction/posts.rkt"
         "../db-interaction/post-struct.rkt")

(define tags (make-parameter null))
(define id (make-parameter -1))

(define (get-commandline-arguments)
  (command-line
    #:program "delete-post.rkt"
    #:once-each
    [("-i" "--id") i
                   "Specify ID of the post to delete"
                   (id i)]
    #:multi
    [("-t" "--tag") t
                    "Specify delete based on tags"
                    (tags (cons t (tags)))]
    (values (string->number id)
            (tags))))

(define )

(module+ main
  (get-commandline-arguments)
  
  (cond
    [(not (equal? (id)
                  -1))
     (posts/remove/id (id))]))