---
title: Specialising on Demand
published: 2014-11-26 00:00:00
---

Introduction
============

The key reason for performing a strictness analysis in our work is to know when it is
*safe* to perform work before it is needed. This work can then be sparked off and
performed in parallel to the main thread of execution. Using the projection-based
analysis we are using allows to know not only *which* arguments are needed, but
*how much* (structurally) of the argument is needed. We convert the projections
into strategies and then spark off those strategies in parallel.

Let's assume that our analysis determines that function `f` needs both of its arguments.
This allows us to convert

```
... f e1 e2 ...
```

into

```
... let a = e1
        b = e2
    in (s1 a) `par` (s2 b) `par` (f a b) ...
```

where `s1` and `s2` are the strategies generated from the projections on those
expressions.


The Problem
===========

Dealing with Different Demands
------------------------------

In the majority of situations there is nothing more to think about. Because each
projection transformer is a function from the demand on a functions result to the
demand on its arguments we can perform the appropriate transformation on `f` for
each demand.

For instance if at another call to the same `f` from above has a lesser demand on
its result, then the transformation might yield

```
... let a = e1
    in (s1 a) `par` (f a e2) ...
```


Different Demands on the Calling Function
-----------------------------------------

The issue is not when a function has two different demands at two calling
sites, that's dealt with 'for free' using the transformation above. The issue is when
there are multiple *possible* demands _at the same call site_.

This can happen when there are different demands on the calling function, for example:


```
func a b = ... f e1 e2 ...
```

Different demands on `func` may (and often will) mean different demands on the result
of `f`. This in turn means that different transformations would be appropriate. Let's
say this results in having two different demands on `f`. One demand results in the
first transformation (the one with two pars) and the other results in the second. How
do we reconcile this possible difference?

Solutions
=========

Safety First
------------

While I can't find how people dealt with this issue in the literature, a sensible
approach would be to take the join of the various demands on `func` and perform the
transformation with the resulting context. This is what I imagine others have done when
facing a similar situation. It is safe, and does not add more code to the program.


More Parallelism (still safe)
-----------------------------

The shame of taking the join of the demands is that it results in the loss of potential
parallelism. Taking a look at the two transformed versions of `f` above, it would be
a shame to only have the second transformation (the one with only one par) just because
it is safer, even though we know that for some calls of `func` it is safe to evaluate
both arguments.

To avoid this we can clone the function `func`. One clone for each demand, allowing
us to have the 'more parallel' version when it is safe, and keep the 'less parallel'
version in the appropriate cases. Note, we do not have to go cloning all the functions
with versions for every possible demand. Instead we can do the following for each
function:

1. Determine which demands are actually present in the program
2. In the body of the function, do the different demands result in differing
    demands for a specific function call?
3. If no, no cloning
4. If yes, clone the function for each demand and re-write the call-sites to call
    the appropriate clone

Applying the above procedure to our hypothetical situation would result in the
following


```
funcD1 a b = ... let a = e1
                     b = e2
                 in (s1 a) `par` (s2 b) `par` (f a b) ...

funcD2 a b = ... let a = e1
                 in (s1 a) `par` (f a e2) ...
```


Conclusion
==========

I think this is an interesting way to further specialise so I've started
implementing it. I am giving myself until the end of tomorrow (Nov. 27th) to have it
fully functional, and then we can even compare the two approaches.
