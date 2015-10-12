---
title: Free Tutorial (Originally for Reid Draper)
published: 2014-06-16 00:00:00
---

From nothing to a simple DSL using Free Monads.
First, some preliminaries:

> module DSL where
> 
> import System.Exit
> 
> type Error = String


First we need to define the constructs of our DSL. Normally we would define
our language as a 'vanilla' recursive type. Something like:

    data DSL = Print String DSL
         | GetChar (Char -> DSL)
         | Halt

This time we'll define factoring out the recursion as a type parameter. 

> data DSLf param = Print String param
>                 | GetLine (String -> param)
>                 | GetChar (Error -> param) (Char -> param)
>                 | Halt 

So our language can print a string, get a char and Halt. Simple enough.

Let's show that our data-type is a Functor

> instance Functor DSLf where
>     fmap f Halt = Halt
>     fmap f (Print str cont) = Print str (f cont)
>     fmap f (GetLine next) = GetLine (f . next)
>     fmap f (GetChar k1 k2) = GetChar (f . k1) (f . k2)

Now let's get back the data-type we *would* have gotten if we'd defined
our language in the 'vanilla' style mentioned above. For this we need
another data-type that can provide the explicit recursion

> data Free f a = Free (f (Free f a))
>               | Pure a

Free takes two types, f and a. f must have kind * -> * and a kind *.
Free is providing the same utility that fix does for functions, creating
a recursive version of a type that was not recursive. 

If we can guarantee that f is a functor, we can make any instantiation of
`Free f a` into a monad

> instance Functor f => Monad (Free f) where
>     return = Pure
>     Pure a >>= f = f a
>     Free x >>= f = Free (fmap (>>= f) x)

It's okay if you don't see the utility of this monad instance yet, later we'll
walk through how it works.

> type DSL = Free DSLf

Now we have our 'proper' DSL.


At this point we could call it a day and start using our DSL. The issue is that
it would be ugly. We'd have to write programs in a very ugly style. Hello world
would look like this:

    hw :: DSL ()
    hw = Free (Print "hello\n" (Free Halt))

Luckily we can abstract away the need to wrap everything in 'Free's and 'Pure's

> liftFree :: Functor f => f a -> Free f a
> liftFree act = Free (fmap Pure act)

Now we can provide user-friendly functions for each of the constructs in our
DSL.

> pr :: String -> DSL ()
> pr str = liftFree $ Print str ()

By the definition of liftFree, this gives us:

    pr str = liftFree $ Print str ()
    pr str = Free (fmap Pure (Print str ())) 
    pr str = Free (Print str (Pure ())) -- Ignoring laziness (which is safe in this case)

The rest follow the same pattern and won't be walked through

> gt :: DSL String
> gt = liftFree $ GetLine id
> 
> getC :: DSL (Either Error Char)
> getC = liftFree $ GetChar (Left . id) (Right . id)
> 
> hlt :: DSL a
> hlt = liftFree Halt

And because `DSL a` is a monad (via the monad instance for Free) we can write
programs using the do notation

> t1 = do
>     pr "hello\n"
>     str <- gt
>     pr $ "Hello again " ++ str

> isFree :: Free f a -> Bool
> isFree (Pure _) = False
> isFree (Free _) = True

Here is the kicker,

`t1` is actually a data structure! 

The line `pr "hello\n"` taken alone would look like:

     Free (Print "hello\n" (Pure ()))

The whole things desugared out of do notation would look like:

    1)  Free (Print "hello\n" (Pure ())) >>
    2)  Free (GetLine (Pure . id)) >>= (\str -> 
    3)  Free (Print ("Hello again " ++ str) (Pure ())))

Because of laziness, this structure stays as it is until something tries
to inspect the first constructor. It *looks* like the first construct is the
Free from line 1, but really the topmost expression is the function `(>>)`
So if you try to inspect the first constructor, you force the application.

Let's give lines 2 + 3 the name 'rest' for now.

Using the definition of `>>` for Free on line 1 we get:

    Free (fmap (>>= (\_ -> rest)) (Print "hello\n" (Pure ())))

If you were needing the result of a function like 'isFree' then this is
where reduction would stop.

If you were trying to interpret the DSL, then we would need to know which of
the DSLf constructors was first inside the Free we've revealed. This forces
the evaluation of the `fmap (>>=` ...

So, using the definition of fmap on DSLfs we get:

    Free (Print "hello\n ((>>= (\_ -> rest)) (Pure ())))
     


> dummyStr = "This is a dummy value"
> 
> dummyChr = Right 'k'
> dummyChr2 = Left "Shh"
> 
> interpDumb :: DSL a -> [String]
> interpDumb (Pure a) = []
> interpDumb (Free Halt) = []
> interpDumb (Free (Print s n)) = s : interpDumb n
> interpDumb (Free (GetLine k)) = interpDumb (k dummyStr)
> interpDumb (Free (GetChar k1 k2)) = interpDumb $ either k1 k2 dummyChr2
> 
> t2 = do
>     str <- gt
>     pr $ "Hello again " ++ (take 2 str)
>     ch <- getC
>     case ch of
>         Left e -> pr e
>         Right c1 -> pr $ take 3 $ repeat c1
> 
> interpIO :: DSL a -> IO a
> interpIO (Pure a) = return a
> interpIO (Free Halt) = exitSuccess
> interpIO (Free (Print s n)) = print s >> interpIO n
> interpIO (Free (GetLine k)) = getLine >>= interpIO . k
> interpIO (Free (GetChar k1 k2)) = do 
>                             ch <- getChar
>                             interpIO $ either k1 k2 $ if ch == '\EOT'
>                                                       then Left "Error"
>                                                       else Right ch
