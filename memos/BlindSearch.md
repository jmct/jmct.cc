---
title: Simon's Search
published: 2013-11-25 00:00:00
---

Introduction
============

Today we met with Simon Poulding and discussed the use of various search
techniques that may be applicable to our iterative compiler. The motivation for
this is the desire to ensure that our straw man is not too naive, and that our
blind search is representative of what one would do if they did not have the
runtime statistics.


Background
----------

The goal of the iterative compiler is to take a functional program that is not
written with parallelism in mind, and create a parallel version of that program.
While the speed gains through this approach may not equal those gained by manual
fine-tuning, the gains are attained 'for free'. In order to show that using the
information gathered from runtime profiling can indeed help us attain better
performance, we need to compare our solution to how a blind search technique
performs. 


Simon's Questions
=================


Simon had a few questions for us after we had described the architecture and our
thoughts on how we would search.

1. Does performance of the test programs depend on the data the program works on
2. Is the measure of the performance deterministic
3. How much time is available for searching
4. Can you know ahead of time how well a "good" solution should perform

Question 1 is addressed by the fact that our benchmark programs will tend to
use data that is representative of the program. 

Question 2 is a definite yes. Currently the measure of performance for the
Iterative Compiler is the number of reductions executed by the G-Machine.
Because our G-Machine is quasi-parallel, this measure is free of any
non-determinism.

Question 3 was not addressed to much depth. The general feel is that we would
prefer to have compilation times on the order of minutes and hours, and not on
the order of days. This is what informed Simon's hierarchy (which we discuss
next).

Question 4 addresses the idea of an optimally parallel program. There is a well
known theory, Amdahl's Law, that can be used to calculate the upper bound on the
performance gains from parallelism:

$$ S(n) = \frac{1}{B + \frac{1}{n}(1 - B)} $$

where $B$ is the fraction of the program that is strictly serial. Often it is
very difficult to know the appropriate value of $B$ for any given program. More
generally, when looking at performance gains from parallelism, you are shooting
to get a linear speedup with the number of cores. 

Simon's Hierarchy
===================

After our initial discussion, Simon suggested a progression that he believes
would be appropriate for our needs. The general theme is that the early steps in
the progression are relatively simple to implement and would also serve as a
contrast to more sophisticated methods. This is generally considered a good
practice in search-based software engineering because you need to demonstrate
that any additional sophistication in the search method used needs to be
justified by the fact that simpler methods do not work just as well, e.g. a
fancy search technique is not very impressive if random search performs just as
well.

Step 0: Random Search
---------------------

As the name suggests, just randomly generate bitstrings of the correct length
and the execute the program. This is the 'true' straw man of the bunch. Limit the
search to some number of iterations and then stop.

Step 0.5: Iterate Through the Bitstring
-------------------------------------

Each program has its switchable par-sites represented by a bitstring of size n,
where n is the number of par-sites. One method to explore the search-space is to
iterate through the bitstring switching only one bit after each execution of the
program. 

So if there are 10 bits in our bitstring, we would run the program 10 times.
After each execution we flip a bit and run the program again, if the program
runs faster, keep the bit as-is, if the program runs slower, switch it back.
Then move to another bit and repeat. Note, the order that you iterate through
the bits could have a huge effect!


Step 1: Hill-Climbing
---------------------

Hill-climbing, while still being simple to implement, can produce good results
when the landscape is smooth enough. In our meeting Simon discussed two
hill-climbing strategies (1 and 3 below) and an additional method was explained
in an email (2).

1. Stochastic hill-climbing: Starting from one random individual, generate a
   neighbor and if that neighbor performs better, the neighbor becomes the new
   individual, repeat.

2. 'Simple' hill-climbing: Iterate through all the neighbors of an individual
   (in a random order) and as soon as one of the neighbors performs better, switch
   to that neighbor. This prevents the possibility of strategy 1 to stop before an
   optimum (local or global) is reached. 
   
3. Steepest Ascent hill-climbing: Calculate the fitness function for _all_ of
   the neighbors of an individual, switch to the best performing neighbor.
   

Step 2: Simulated Annealing
---------------------------

Simulated annealing avoids some of the drawbacks of hill-climbing. Mainly, SA is
less likely to terminate on a non-global optimum. 

This is achieved by allowing a hill-climbing search to move 'downward' according
to some probability. Initially, the probability can start relatively high, and
as the search progresses this probability decreases. 

Simulated Annealing is the first in the hierarchy to have a fine-tuned parameter
(the initial temperature and the rate of cooling). This would mean that
experiments would need to be run in order to find suitable settings of these
parameters for our purposes.

Step 3: Genetic Algorithms
--------------------------

Genetic Algorithms have some desirable properties at the cost of increased
complexity and resources required. Unlike the strategies mentioned earlier, GAs
are able to cope with the dependencies between bits in the bitstring. This
property is gained via the use of crossover.

There are two main concerns with the use of GAs for our needs.

1. There are many different parameters that needs to be set for a
   well-performing GA. Population size, mutation rates, crossover patterns, size of
   generations (elitism). It is not clear that one setting of these parameters
   would work across a set of programs. 
   
2. Iterating through the algorithm becomes much more expensive, a population of
   50 requires 50 executions of the program before the next generation in the GA
   can be calculated. 


Step 4: Estimation of Distribution Algorithms
---------------------------------------------

EDAs are a generation based algorithm where members of the generation are
sampled from a probability distribution that is built from the previous
generation. The probability distributions that are built during the search can
also be used for more targeted local search using other techniques. In this way
EDAs not only perform well as a search technique in their own right, but can
be used to inform other search techniques.

As with GAs, EDAs require a lot of resources to use, and it is still unclear
whether any parameter settings for an EDA will generalise across input programs.
