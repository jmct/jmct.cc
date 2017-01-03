---
title: Introduction
published: 2016-12-23 00:00:00
---

Preface
=======

This is the first in a series of posts about what I am calling the "Burge
School of Functional Programming". When I originally
[tweeted](https://twitter.com/josecalderon/status/804154036375187458) that I was
going to do this, I called it the "Burge-Runciman" School, but upon further
reflection I think that they are distinct and I was being clouded by the fact
that it was [Colin Runciman](https://www-users.cs.york.ac.uk/colin/) who taught me
about Burge.

Motivation
----------

There has been a lot of discussion online in the past few years about what
Functional Programming _is_. This discussion comes in waves and we recently had
a high-point when a list claiming to classify levels of Functional Programming
was widely distributed.

I, as well as many of my colleagues, found the list a bit disconcerting. It is a
dangerous game to try and make such a prescriptive list about a topic; it is a
near certainty that any benefits of such a list are far outweighed by the
likelihood of any such list alienating those who are looking to get started in
Functional Programming.

Independent of the situation I just described, I've been dissatisfied with the
attitude that Haskell is the 'truest' Functional Language, or that it somehow
exhibits FP in its 'purest' form. Because of this I have wanted to write about
some Functional Programming history for a few years now. In particular I want to
draw some attention to William H. Burge's book "Recursive Programming
Techniques", which is a (sometimes forgotten) gem of Functional Programming.

Background
----------

When I was a PhD student at York, I remember reading a paper about parser
combinators in Haskell. I went into Colin Runciman's office and expressed my
joy, and in particular I expressed something like "it's amazing that they were
able to come up with something like that!". This was early days of my PhD when I
still wasn't so great at identifying what's _actually_ novel in a paper. Colin
told me to wait a minute and he went to his bookshelf and grabbed an old book:
"Recursive Programming Techniques" by William H. Burge. He suggested I read it.

The book was first published in 1975, three years before Backus' famous Turing
award lecture ["Can programming be liberated from the von Neumann
style?"](http://dl.acm.org/citation.cfm?id=359579), which is often seen as a
watershed moment in the history of functional programming because it brought so
much attention to the field. In my view Burge's book has aged much better than
Backus' lecture, but that is likely due to other factors.[^1]

[^1]: Backus was trying to do more than just explain functional programming in
his lecture, he was trying to turn the tide of programming language research.
Because of this some of the technical work in the lecture has not aged super
well. For instance in certain parts of the paper Backus emphasises point-free
programming using an APL-style syntax. In the decades since the general
consensus has moved away from this style.

The Burge School
================

Burge's book is, in my opinion, one of the best publications on what functional
programming is about. This is made even more intriguing when you think about
what _wasn't_ around when this book was first published. In 1975 we did _not_
have:

* Polymorphic Type Inference
* Algebraic Data types
* Lazy languages[^2]
* Lots of Category-theoretic terminology as part of functional programming

This is in contrast to how many commentators online talk about functional
programming. However, much in the same way that music is not a set of
instruments, functional programming is not a set of abstractions that we need to
learn and memorize. Functional programming is an _approach_ to solving
computational problems.

Many of the abstractions that you do read about are ways to apply this approach
to new problems, or problems that were difficult to solve without reaching for
more traditional programming methods. But the essence, the core, of what
functional programming is about is mostly unchanged.

In the preface to the book Burge writes (emphasis mine):

> The main emphasis [of this book] is placed on those parts of the language,
> namely expressions, that denote the end results sought from the computer,
> rather than on the instructions which the machine must follow in order to
> achieve the results. _The main thesis of this book is that, in many cases,
> this emphasis on expressions as opposed to mechanisms simplifies and
> improves the task of programming._

The above will be familiar to anyone who has had the good fortune of taking
a well designed functional programming course. This is the paradigm shift that
sometimes makes functional programming hard to learn for those that are used to
other methods of programming. Expressions over mechanisms.

The Book
--------

Part of what makes this book so interesting is that it was published as part of
a series on programming from IBM. The series was called "The Systems Programming
Series" and its charter was

> a long term project to collect, organize, and publish those principles and
> techniques that would have lasting value throughout the industry.

IBM was trying to combat the tendency for systems programmers to all continually
reinvent the wheel. In other words, this was not a series for the navel gazers
in the Ivory Tower, this was for those on the ground programming real systems
and solving 'real world' problems. Granted, the programming tasks of the day
weren't necessarily the same tasks that a programmer today might be focusing on,
but the tools and techniques are more similar than one might think. 

The book itself is divided into 5 chapters:

1. Basic Notions and Notations
2. Program Structure
3. Data Structures
4. Parsing
5. Sorting

In the coming weeks we will take a look at each chapter and highlight Burge's
insights. The goal here is to provide a counter to the checklist approach to
functional programming material. The core ideas are all here, my hope is that
once those are internalized a lot of the modern discourse on Functional
Programming can be seen in a new light.

Epilogue
--------

Many of the older functional programmers I know were big Prog Rock fans. I find
it fitting that many of those that were early proponents of what was a radical
programming methodology were into radical music as well. I don't know Burge, but
I like to imagine that the soundtrack of the 1970's was in the air as he was
writing this book. With that spirit I'm going to link to a Prog Rock hit from
the early to mid 1970's with each post; because, why not?

So, for all of those early functional programmers that were called 'dreamers':

<iframe width="560" height="315" src="https://www.youtube.com/embed/xkkvBfWAXgI"
frameborder="0" allowfullscreen></iframe>

[^2]: There were call by name languages, and the concept of a delayed
computation or a 'thunk' was already well known. But I'd argue that the study of
laziness _as a discipline_ really only took off in the later 1970's with the
famous papers ["A Lazy Evaluator"](http://dl.acm.org/citation.cfm?id=811543)
(1976) and ["CONS should not Evaluate its
Arguments"](http://www.cs.indiana.edu/cgi-bin/techreports/TRNNN.cgi?trnum=TR44)
(also 1976). Let me know if I've missed something there.

-JMCT
