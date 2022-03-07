---
title: Quick and Dirty Mirroring for Historians
published: 2022-03-07 00:00:00
---

Introduction
============

It's possible that Russia will disconect or be disconnected from the global
internet, with some reports saying that this will occur by Friday. I am unsure
how likely this is, but they have practiced this [in the
past](https://www.bbc.com/news/technology-50902496). Regardless, lots of folks
who depend on Russian websites and resources for their work are a reasonably
concerned. This is a very rough guide to how you might be able to download
those resources for your own use offline.

Disclaimer:
-----------

We're going to skip over a lot of the _why_, we're doing the things I describe
below. Normally, I'd want to motivate it and ensure that you're all empowered by
understanding the tools you're using, but there isn't time for that today, maybe
another time.

Get `wget`
==========

You'll need `wget`, which is a tool for 'getting' resources from the web.[^1]

Mac
---

If you're on a Mac, the easiest way is to open up `Terminal` (use spotlight to
open up the terminal) and type the following command:


```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Once that finishes, check that it worked by running the following (the dashes,
(`--`) matter):


```
brew --version
```

If you get back something along the lines of "brew not found" then the command
didn't work. I'm sorry. You can try emailing me, but it's going to be hard to
figure out what went wrong remotely. If you got back a message saying what
version you're running, great! Run the following:


```
brew install wget
```

Once that is complete, we're going to do a similar test to see if it worked:

```
wget --version
```

If you get something like `command not found`, it didn't work. I'm sorry.
Otherwise, you've now installed `wget`, which is the main tool we need.
Skip to "Using wget".

Windows
-------

If you're on Windows, [this site](https://eternallybored.org/misc/wget/) seems
to be the most straightforward way of getting `wget` running on your system. I
do not have a Windows system to test this, unfortunately. If you have issues,
reach out to me and I can clarify this section with more details.


Using `wget`
============

Having installed `wget` we can now mirror (a.k.a. clone) some webpages. The
distinction between which webpages this will work on and which it will not, are
well beyond the scope of this post. For now, just try it. The worst case is that
it won't work. You're unlikely to break anything.

Testing a single page
---------------------

One of the issues of using `wget` is that you may accidentally bite off more
than you chew, webpages can be very large and your local storage may not be
big enough. Additionally, the bigger the webpage, the longer this will take,
with no guarantee that it'll work when it's completed its job. Because of this,
it's important to test it on a small part of what you care about.

For example, if you wanted to mirror this website of a [Russian and Soviet
Journal](http://zhurnalko.net/journal-204), it will be wise to try and see
if you can mirror one issue first. So let's try to mirror [the first issue from
2007](http://zhurnalko.net/=sam/junyj-tehnik/2007-01). Below is the command that
will try to mirror this particular page, but before you copy/paste it, read a
little bit further so that you know how to change it to your needs:



```
wget --mirror --convert-links --adjust-extension --page-requisites --no-parent -l 1 http://zhurnalko.net/=sam/junyj-tehnik/2007-01
```

Everything from the `wget` to the `--no-parent` can be taken as a given for our
'Quick and Dirty' explanation.

The two important things for you are the following:

* `-l SOME_NUMBER`
* The URL (`http://zhurnalko.net/=sam/junyj-tehnik/2007-01`, in this case)

The `-l` represents _how deep_ we want this mirror to go. You never want this
number to be very high as it'll try to download non-trivial portions of the
internet. I've never used a number larger than `-l 5`, for instance and that can
still take many many hours. Here we've started with `-l 1` because we want this
exact page _and to follow each link on this page_, the '1' means "only go one
page deeper". Don't ever use `-l 0` though as that means 'infinite', which you
don't want, I promise.

The URL is the page we want to start from, in this case the first issue of 2007.

Now, when you run the command, it may take a bit of time. Just be patient, don't
put your computer to sleep or turn it off, or close your terminal/command
prompt. Just let it do it's thing. At some point, it will finish and you may get
a message like the following:

```
Converted links in 87 files in 0.02 seconds.
```

Here, the `0.02` seconds is not for the overall process, but for the final step
in making it available offline. The overall process took me about 5 minutes for
this particular page.

Viewing the mirrored site
-------------------------

Unfortunately, this next part is going to be a bit different for each webpage.
There's not universal standard. I'll try to explain what you're looking for via
our running example.

You'll have a folder hierarchy that matches the URL you mirrored. In this case
that means we'll have a folder called `zhurnalko.net/`, and in the folder will
be a folder called `=sam/`, which will have a folder called `junyj-tehnik/`. In
that folder you're going to look for something that is potentially called
`index.html`, or `index.htm`. Sometimes, as is the case in our running example,
it's named the same as the _last_ part of the URL: `2007-01.html`, in this case.

If you try to open that (double click on it), you should be able to view the
files.

Grabbing a bit more
-------------------

Once you're satisfied that the mirroring works, you can try to mirror a bit more
of the website. This will require you going 'up' a level in the website, and
adding 1 to the `-l` value you used. Remember, if that value starts getting
large (you should consider 3 or greater to be large!), you're trying to mirror
too much and need to find a way to be more targeted.

In the case of the site we're trying to mirror, one level up would be
`http://zhurnalko.net/journal-204`, which has all the issues of that journal. We
would then add 1 to `-l` and it would look like the following:

```
wget --mirror --convert-links --adjust-extension --page-requisites --no-parent
-l 2 http://zhurnalko.net/journal-204
```

To say that this could take significantly more time is an understatement. I ran
the above over an hour ago and it's still chugging along!

Once it completes its job, you're going to want to find that initial page (see
"Viewing the mirrored site" above) and you're all set to use those files
offline.


[^1]: This is an unusually clear name for modern software!



-JMCT
