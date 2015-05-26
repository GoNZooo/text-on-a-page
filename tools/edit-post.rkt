#lang racket/base

(require racket/contract
         racket/cmdline

         markdown ; Brilliant markdown lib by greghendershott

         "../db-interaction/posts.rkt"
         "../db-interaction/post-struct.rkt"
         "make-post.rkt")

(define tags (make-parameter null))
(define name (make-parameter ""))
(define id (make-parameter 0))
(define body (make-parameter ""))

(define (get-commandline-arguments)
  (command-line
    #:program "edit-post.rkt"
    #:once-each
    [("-n" "--name") n
                     "Set the name (title) of the post"
                     (name n)]
    [("-b" "--body") body-filename
                     "Set the body of the post"
                     (body (build-file body-filename))]
    #:multi
    [("-t" "--tag") t
                    "Specify a tag for the post"
                    (tags (cons t (tags)))]
    #:args (id)
    (values (name)
            (string->number id)
            (body)
            (reverse (tags)))))

(define/contract (make-edits id name body tags)
  (real? string? string? (listof string?) . -> . void?)
  
  (when (not (equal? name ""))
    (posts/edit/title/id id name))
  (when (not (equal? body ""))
    (posts/edit/body/id id body))
  (when (not (null? tags))
    (posts/edit/tags/id id tags)))

(module+ main
  (define-values (n i b t) (get-commandline-arguments))
  (make-edits i n b t))
