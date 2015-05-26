#lang racket/base

(require racket/contract
         racket/cmdline

         markdown ; Brilliant markdown lib by greghendershott

         "../db-interaction/posts.rkt"
         "../db-interaction/post-struct.rkt")

(provide build-file)

(define input-file (make-parameter ""))
(define tags (make-parameter null))
(define name (make-parameter ""))

(define (get-commandline-arguments)
  (command-line
    #:program "make-post.rkt"
    #:once-each
    [("-n" "--name") n
                     "Set the name (title) of the post"
                     (name n)]
    #:multi
    [("-t" "--tag") t
                    "Specify a tag for the post"
                    (tags (cons t (tags)))]
    #:args (filename)

    filename))

(define/contract (parse-file filename)
  (string? . -> . list?)

  (parse-markdown (build-path filename)))

(define/contract (make-post-body xs)
  (list? . -> . string?)

  (xexpr->string `(div ([class "post_body"])
                       ,@xs)))

(define/contract (build-file filename)
  (string? . -> . string?)

  (make-post-body (parse-file filename)))

(define/contract (upload-post tags name filename)
  ((listof string?) string? string? . -> . void?)
  
  (posts/insert (post 0
                      tags
                      name
                      (build-file filename)
                      #f)))

(module+ main
  (define filename (get-commandline-arguments))
  (upload-post (tags)
               (name)
               filename))
