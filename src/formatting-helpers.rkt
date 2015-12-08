#lang racket/base

(require racket/contract)

(provide format-tag-links)

(define/contract (format-tag-links ts)
  ((listof string?) . -> . string?)

  (define (tag/out t)
    (format "<span class=\"post_tag\"><a href=\"/text/view/~a\">~a</a>"
            t t))

  (if (= (length ts) 1)
      (tag/out (car ts))
      (format "~a,~a"
              (tag/out (car ts))
              (format-tag-links (cdr ts)))))
