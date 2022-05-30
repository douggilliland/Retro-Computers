# Contributing to the PiDP-8/I Project

If you wish to make any changes to [the project’s files][home], here are
some rules and hints to keep in mind while you work.

[home]: https://tangentsoft.com/pidp8i/


## <a id="gs-fossil"></a> Getting Started with Fossil

The PiDP-8/I software project is hosted using the Fossil
[distributed version control system][dvcs], which provides most of the
features of GitHub without [the complexities of Git][fvg].

Those new to Fossil should at least read its [Quick Start Guide][fqsg].
If you want to go deeper, [the Schimpf book][fbook] is somewhat
outdated, but it is still the best single coherent tutorial on Fossil.
Those coming from Git will benefit from the approach taken by the
“[Git to Fossil Translation Guide][gitusr].”

[The official Fossil docs][fdoc] are much more up to date, but they take
a piecemeal approach to topics, rather than the linear tutorial approach
of a book, so it is not my first recommendation for learning Fossil.
Those docs are better for polishing your skills and for reference after
you know Fossil reasonably well.

If you have questions about Fossil, ask on [the Fossil forum][ffor]
where I, your humble project maintainer, am active. I also work on the
Fossil docs quite a bit, so if your question really isn’t answered
somewhere in the above material, I might just solve it by extending the
Fossil docs.

Fossil is pre-installed on our [binary OS images][bosi] since April
2017.

When starting from Debian-based OSes released in June 2019 or newer,
this will work:

    $ sudo apt install fossil

Older Debian-based OSes will give you Fossil 1.*x*, which won’t work with
our repository, which requires Fossil 2.1 or higher. If you can’t
upgrade your host OS, you’ll have to [build Fossil from source][bffs].

Fossil is also available for all common desktop platforms. If your OS
package repository doesn’t include Fossil 2.1 or higher already, one of
the [precompiled binaries][fbin] may work on your system.


[bffs]:   https://fossil-scm.org/home/doc/trunk/www/build.wiki
[bosi]:   https://tangentsoft.com/pidp8i#bosi
[fbin]:   https://fossil-scm.org/index.html/uv/download.html
[fvg]:    https://fossil-scm.org/home/doc/trunk/www/fossil-v-git.wiki
[dvcs]:   https://en.wikipedia.org/wiki/Distributed_revision_control
[fbook]:  https://www.fossil-scm.org/schimpf-book/home
[fdoc]:   https://fossil-scm.org/home/doc/trunk/www/permutedindex.html
[ffor]:   https://fossil-scm.org/forum/
[fqsg]:   https://fossil-scm.org/home/doc/trunk/www/quickstart.wiki
[gitusr]: https://fossil-scm.org/home/doc/trunk/www/gitusers.md


## <a id="fossil-anon" name="anon"></a> Fossil Anonymous Access

There are three ways to clone the repository anonymously using Fossil.
Each of these methods gets you a file called `pidp8i.fossil` containing
the full history of the PiDP-8/I software project from the upstream
2015.12.15 release onward.

You only need to take one of these options, once per machine.
Thereafter, you will just be working with the cloned repository.


### One-Step Clone-and-Open <a id="one-step-open"></a>

The easiest way requires Fossil 2.14 or higher:

    $ fossil clone https://tangentsoft.com/pidp8i
    $ cd pidp8i

That gets you a clone of the `pidp8i.fossil` repository plus a check-out
of the current trunk in a `pidp8i/` directory alongside it. We recommend
that you do this in a directory like `~/src` so you don’t commingle
these files with other things in your current working directory.


### Open from URI <a id="open-uri"></a>

If you have Fossil 2.12 or 2.13, the next-easiest method is:

    $ mkdir -p ~/src/pidp8i
    $ cd ~/src/pidp8i
    $ fossil open https://tangentsoft.com/pidp8i

This opens the repository referenced by that URI into the current
directory as `pidp8i.fossil`, then opens that repo into that same
subdirectory.

You have to create the destination directory first with this method
because Fossil will refuse to spam a non-empty directory with the
check-out contents when opening the repo into a directory containing
other files unless you give it the `--force` flag.

Notice that the repo file ends up *inside* the check-out tree with this
method. This is because of a purposeful semantic difference in Fossil
between “open” and “clone.” It may seem strange to someone coming from
Git, but while we don’t want to get into the whys and wherefores here,
realize there is logic behind this choice.


### Separate Clone and Open <a id="sep-clone-open"></a>

The complicated method works with all versions of Fossil back to 2.1,
and it is the one we recommend to people who want to get involved with
the project, because it has [numerous advantages][cowf] over the easy
methods. We’ll explain those benefits in the context of the PiDP-8/I
project later, but for now, the method is:

    $ mkdir -p ~/museum ~/src/pidp8i/trunk
    $ fossil clone https://tangentsoft.com/pidp8i ~/museum/pidp8i.fossil
    $ cd ~/src/pidp8i/trunk
    $ fossil open ~/museum/pidp8i.fossil

[cowf]: https://fossil-scm.org/home/doc/trunk/www/ckout-workflows.md


## <a id="login"></a> Fossil Developer Access

If you have a developer account on the `tangentsoft.com/pidp8i` Fossil
instance, just add your username to the URL like so:

    $ fossil clone https://USERNAME@tangentsoft.com/pidp8i pidp8i.fossil

If you’ve already cloned anonymously, simply tell Fossil about the new
sync URL instead:

    $ cd ~/src/pidp8i/trunk
    $ fossil sync https://USERNAME@tangentsoft.com/pidp8i

Either way, Fossil will ask you for the password for `USERNAME` on the
remote Fossil instance, and it will offer to remember it for you. If
you let it remember the password, operation from then on is scarcely
different from working with an anonymous clone, except that on checkin,
your changes will be sync’d back to the repository on tangentsoft.com if
you’re online at the time, and you’ll get credit under your developer
account name for the checkin.

If you’re working offline, Fossil will still do the checkin locally, and
it will sync up with the central repository after you get back online.
It is best to work on a branch when unable to use Fossil’s autosync
feature, as you are less likely to have a sync conflict when attempting
to send a new branch to the central server than in attempting to merge
your changes to the tip of trunk into the current upstream trunk, which
may well have changed since you went offline.

You can purposely work offline by disabling autosync mode:

    $ fossil set autosync 0

Until you re-enable it (`autosync 1`) Fossil will stop trying to sync
your local changes back to the central repo. In this mode, Fossil works
more like Git’s default mode, buying you many of the same problems that
go along with that working style. I recommend disabling autosync mode
only when you are truly going to be offline and don’t want Fossil
attempting to sync when you know it will fail.


## <a id="gda"></a> Getting Developer Access

We’re pretty open about giving developer access to someone who’s
provided at least one good, substantial [patch](#patches) to the
software. If we’ve accepted one of your patches, just ask for a
developer account [on the forum][pfor].


## <a id="tags" name="branches"></a> Working with Existing Tags and Branches

The directory structure shown in the [separate clone and
open](#sep-clone-open) sequence above is more complicated than strictly
necessary, but it has a number of nice properties.

First, it collects software projects under a common top-level
directory. I’ve used `~/src` for this example, but you are free to use any scheme
you like.

Second, the level underneath the project directory (`~/src/pidp8i`) stores multiple separate
checkouts, one for each version the developer is actively working with at the moment,
so to add a few other checkouts, you could say:

    $ cd ~/src/pidp8i
    $ mkdir -p release          # another branch
    $ mkdir -p v20151215        # a tag this time, not a branch
    $ mkdir -p 2019-04-01       # the software as of a particular date
      ...etc...
    $ cd release
    $ fossil open ~/museum/pidp8i.fossil release
    $ cd ../v20151215
    $ fossil open ~/museum/pidp8i.fossil v20151215
    $ cd ../2019-04-01
    $ fossil open ~/museum/pidp8i.fossil 2019-04-01
      ...etc...

This gives you multiple independent checkouts, which allows you to
quickly switch between versions with “`cd`” commands. The alternative
(favored by Git and some other version control systems) is to use a
single working directory and switch among versions by updating that
single working directory in place. The problem is that this
invalidates all of the build artifacts tied to changed files, so you
have a longer rebuild time than simply switching among check-out
directories. Since disk space is cheap these days — even on a small
Raspberry Pi SD card – it’s better to have multiple working states and
just “`cd`” among them.

When you say `fossil update` in a check-out directory, you get the “tip”
state of that version’s branch. This means that if you created your
“`release`” check-out while version 2017.01.23 was current and you say
“`fossil update`” today, you’ll get the release version 2019.04.25 or
later. But, since the `v20151215` tag was made on trunk, saying
“`fossil update`” in that check-out directory will fast-forward you to the tip of
trunk; you won’t remain pinned to that old version. This is one of the
essential differences between tags and branches in Fossil, which are at
bottom otherwise nearly identical.

The PiDP-8/I project uses tags for [each released version][tags], and it
has [many working branches][brlist]. You can use any of those names in
“`fossil open`” and “`fossil update`” commands, and you can also use any
of [Fossil’s special check-in names][fscn].

[brlist]: https://tangentsoft.com/pidp8i/brlist
[fscn]:   https://fossil-scm.org/home/doc/trunk/www/checkin_names.wiki
[fvg]:    https://fossil-scm.org/home/doc/trunk/www/fossil-v-git.wiki
[gitwt]:  https://git-scm.com/docs/git-worktree
[tags]:   https://tangentsoft.com/pidp8i/taglist


## <a id="branching"></a> Creating Branches

Creating a branch in Fossil is scary-simple, to the point that those
coming from other version control systems may ask, “Is that really all
there is to it?” Yes, really, this is it:

    $ fossil ci --branch new-branch-name

That is to say, you make your changes as you normally would; then when
you go to check them in, you give the `--branch` option to the
`ci/checkin` command to put the changes on a new branch, rather than add
them to the same branch the changes were made against.

While developers with login rights to the PiDP-8/I Fossil instance are
allowed to check in on the trunk at any time, we recommend using
branches whenever you’re working on something experimental, or where you
can’t make the necessary changes in a single coherent checkin.

One of this project’s core principles is that `trunk` should always
build without error, and it should always function correctly. That’s an
ideal we have not always achieved, but we do always *try* to achieve it.

Contrast branches, which PiDP-8/I developers may use to isolate work
until it is ready to merge into the trunk. It is okay to check work in
on a branch that doesn’t work, or doesn’t even *build*, so long as the
goal is to get it to a point that it does build and work properly before
merging it into trunk.

Here again we have a difference with Git: because Fossil normally syncs
your work back to the central repository, this means we get to see the
branches you are still working on. This is a *good thing*. Do not fear
committing broken or otherwise bad code to a branch. [You are not your
code.][daff] We are software developers, too: we understand that
software development is an iterative process, that not all ideas
spring forth perfect and production-ready from the fingers of its
developers. These public branches let your collaborators see what
you’re up to; they may be able to lend advice, to help with the work, or
to at least be unsurprised when your change finally lands in trunk.

Fossil fosters close cooperation, whereas Git fosters wild tangents that
never come back home.

Jim McCarthy (author of [Dynamics of Software Development][dosd]) has a
presentation on YouTube that touches on this topic at a couple of
points:

*   [Don’t go dark](https://www.youtube.com/watch?v=9OJ9hplU8XA)
*   [Beware of a guy in a room](https://www.youtube.com/watch?v=oY6BCHqEbyc)

Fossil’s sync-by-default behavior fights these negative tendencies.

PiDP-8/I project developers are welcome to create branches at will. The
main rule is to follow the branch naming scheme: all lowercase with
hyphens separating words. See the [available branch list][brlist] for
examples to emulate.

If you have checkin rights on the repository, it is generally fine to
check things in on someone else’s feature branch, as long as you do so
in a way that cooperates with the purpose of that branch. The same is
true of `trunk`: you should not check something in directly on the trunk
that changes the nature of the software in a major way without
discussing the idea first. This is yet another use for branches: to
make a possibly-controversial change so that it can be discussed before
being merged into the trunk.

[daff]: http://www.hanselman.com/blog/YouAreNotYourCode.aspx
[dosd]: http://amzn.to/2iEVoBL


## <a id="special"></a> Special Branches

Most of the branches in the PiDP-8/I project are feature branches of the
sort described in the previous section: an isolated line of development
by one or more of the project’s developers to work towards some new
feature, with the goal of merging that feature into the `trunk` branch.

There are a few branches in the project that are special, which are
subject to different rules than other branches:

*   **<code>release</code>** — One of the steps in the
    [release process][relpr] is to merge the stabilized `trunk` into the
    `release` branch, from which the release tarballs and binary OS
    images are created. Only the project’s release manager — currently
    Warren Young — should make changes to this branch.

*   **<code>bogus</code>** or **<code>BOGUS</code>** — Because a branch
    is basically just a label for a specific checkin, Fossil allows the tip
    of one branch to be “moved” to another branch by applying a branch
    label to that checkin. We use this label when someone makes a
    checkin on the tip of a branch that should be “forgotten.” Fossil
    makes destroying project history very difficult, on purpose, so
    things moved to the “bogus” branch are not actually destroyed;
    instead, they are merely moved out of the way so that they do not
    interfere with that branch’s normal purpose.

    If you find yourself needing to prune the tip of a branch this way,
    the simplest way is to do it via the web UI, using the checkin
    description page’s “edit” link. You can instead do it from the
    command line with the `fossil amend` command.

[relpr]: https://tangentsoft.com/pidp8i/doc/trunk/doc/RELEASE-PROCESS.md


## <a id="forum"></a> Developer Discussion Forum

The “[Forum][pfor]” link at the top of the Fossil web interface is for
discussing the development of the PiDP-8/I software only. All other
traffic should go to [the end-user focused mailing list][ggml] instead. We’re not trying
to split the community by providing a second discussion forum; we just
think many development-related discussions are too low-level to be of
any interest to most of the people on the mailing list.

You can sign up for the forums without having a developer login, and you
can even post anonymously. If you have a login, you can [sign up for
email alerts][alert] if you like.

Keep in mind that posts to the Fossil forum are treated much the same
way as ticket submissions and wiki articles. They are permanently
archived with the project. The “edit” feature of Fossil forums just
creates a replacement record for a post, but the old post is still
available in the repository. Don’t post anything you wouldn’t want made
part of the permanent record of the project!

[ggml]: https://groups.google.com/forum/#!forum/pidp-8
[pfor]: https://tangentsoft.com/pidp8i/forum
[alert]: https://tangentsoft.com/pidp8i/alerts


## <a id="debug"></a> Debug Builds

By default, the build system creates a release build, but you can force
it to produce a binary without as much optimization and with debug
symbols included:

    $ ./configure --debug-mode
    $ make clean
    $ tools/mmake


## <a id="build-system"></a> Manipulating the Build System Source Files

The [autosetup build system][asbs] is composed of these files and
directories:

    auto.def
    autosetup/*
    configure
    Makefile.in

Unlike with GNU Autoconf, which you may be familiar with, the
`configure` script is not output from some other tool. It is just a
driver for the generic Tcl and C code under the `autosetup` directory,
which in turn runs the project-specific `auto.def` Tcl script to
configure the software. Some knowledge of [Tcl syntax][tcldoc] will
therefore be helpful in modifying `auto.def`.

If you have to modify any of the files in `autosetup/` to get some
needed effect, you should try to get that change into the upstream
[Autosetup][asbs] project, then merge that change down into the local
copy when it lands upstream.

If you do not have Tcl installed on your system, `configure` builds a
minimal Tcl interpreter called `jimsh0`, based on the [Jim Tcl][jim]
project. Developers working on the build system are encouraged to use
this stripped-down version of Tcl rather than “real” Tcl because Jim Tcl
is a mostly-pure subset of Tcl, and `jimsh0` is a subset of the complete
Jim Tcl distribution, so any changes you make that work with the
`jimsh0` interpreter should also work with “real” Tcl, but not vice
versa. If you have Tcl installed and don’t really need it, consider
uninstalling it to force Autosetup to build and use `jimsh0` to ensure
that your changes to `auto.def` work on both interpreters.

The `Makefile.in` file is largely a standard [GNU `make`][gmake] file
excepting only that it has variables substituted into it by Autosetup
using its `@VARIABLE@` syntax. At this time, we do not attempt to
achieve compatibility with other `make` programs, though in the future
we may need it to work with [BSD `make`][bmake] as well, so if you are
adding features, you might want to stick to the common subset of
features implemented by both the GNU and BSD flavors of `make`. We do
not anticipate any need to support any other `make` flavors.

This, by the way, is why we’re not using some heavy-weight build system
such as the GNU Autotools, CMake, etc.

The primary advantage of GNU Autotools is that you can generate
standalone source packages that will configure and build on weird and
ancient flavors of Unix. We don’t need that.

Cross-platform build systems such as CMake ease building the same
software on multiple disparate platforms, but the PiDP-8/I software is
built primarily on and for a single operating system, Raspberry Pi OS,
né Raspbian. It also happens to build and run on [several other
OSes][oscomp], for which we also do not need the full power of something
like CMake. Autosetup and GNU `make` suffice for our purposes here.

[asbs]:   http://msteveb.github.io/autosetup/
[bmake]:  https://www.freebsd.org/doc/en/books/developers-handbook/tools-make.html
[gmake]:  https://www.gnu.org/software/make/
[jim]:    http://jim.tcl.tk/
[oscomp]: https://tangentsoft.com/pidp8i/wiki?name=OS+Compatibility
[tcldoc]: http://wiki.tcl.tk/11485


## <a id="dirs"></a> Directory Structure

The directory structure of the PiDP-8/I project is as follows:

*   <b>`.`</b> — Top level, occupied only by the few files the end user
    of the source code needs immediately at hand on first unpacking the
    project: the top level build system files, key documentation, and
    licensing information. If a given file *can* be buried deeper, it
    *should* be buried to reduce clutter at this most precious level of
    the hierarchy.

*   <b>`.fossil-settings`</b> — Versioned settings for the Fossil build
    system which Fossil applies as defaults everywhere you check out a
    Fossil version. Settings made here are intended to be correct for
    all users of the system; think of these not as expressing defaults
    but as expressing *policy*. It is possible to override these
    settings, but we do not make settings here if we expect that some
    users may quibble with our choices here.

    Any setting whose value may vary between users of the Fossil
    repository should be done locally with a [`fossil setting` command][fscmd]
    rather than by creating or editing files in this subdirectory.

    See [the Fossil settings documentation][fset] for more on this.

*   <b>`autosetup`</b> — The bulk of the [Autosetup build system][asbs].
    These are generic files, not modified by the project itself. We
    occasionally run `tools/autosetup-update` to merge in upstream
    changes.

*   <b>`bin`</b> — Programs installed to `$prefix/bin`, which may also
    be run during development, if only to test changes to those
    programs. Some scripts stored here are written in place by the
    project’s developers, while other files in this directory are
    outputs of the build system.

    A subset of this directory’s content is copied to `$prefix/bin` at
    installation time, which is added to the user’s `PATH` by the
    `make install` script. We don’t copy the whole thing as-is because
    the build system places some files here that get installed to other
    locations or which don’t get installed at all.

*   <b>`boot`</b> — SIMH initialization scripts. The `*.script.in`
    files are written by the project developers but have local
    configuration values substituted in by the `configure` script to
    produce a `*.script` version. Scripts which need no config-time
    values substituted in are checked in directly as `*.script`. The
    `*.script` files in this directory which do not fall into either of
    those categories are outputs of `tools/mkbootscript`, which produces
    them from `palbart` assembly listings.

    All of these `*.script` files are copied to `$prefix/share/boot` by
    `make mediainstall` which runs automatically from `make install`
    when we detect that the binary media and SIMH boot scripts have
    never been installed at this site before. On subsequent installs,
    the user chooses whether to run `make mediainstall` by hand to
    overwrite all of this.

*   <b>`doc`</b> — Documentation files that can wait for new users to
    discover them, which do not need to be available immediately to the
    user on inspecting the tree for the first time.

    Fossil’s [embedded documentation][edoc] feature allows us to present
    the contents of `doc` to web site users all but indistinguishably
    from a wiki page.

    You may then ask, “Why are there two different ways to achieve the
    same end — embedded docs and the wiki — and how do we decide which
    mechanism to use?” Let us explore the differences before we answer
    the question.

    Fossil’s wiki feature behaves much like Wikipedia: it keeps change
    history for wiki documents, but it always presents the most recent
    version unless you go out of your way to manually dig up a
    historical version. This is true even if you’ve run `fossil ui` from
    a check-out directory where you’ve rolled back to a historical
    version. This doesn’t roll back the wiki to the same point in time;
    it continues showing the most recent version of each article.

    Embedded documentation — being files like any other committed to the
    repository — *are* rolled back to historical versions when you say
    something like `fossil update 2018-04-01` to see the software as of
    April Fool’s Day 2018. You see the embedded docs as of that date as
    well, unlike with the wiki.

    That leads us to the razor we use to decide where a given document
    lives.

    Use the wiki for evergreen content: material likely to remain
    correct for future versions of the software as well as the version
    contemporaneous with the initial version of the document. Also use
    the wiki for documention of conditions that change independently of
    the software’s version history, a good example being [our OS
    Compatibility wiki article][oscomp]. In either case, there is no tie
    between the software’s internal version history and changes out in
    the wider world, so the wiki’s always-current nature matches our
    needs well.

    The best case for using embedded documentation is when
    changes to the software are likely to require changes to the
    corresponding documentation, so that the commit changes both docs
    and code, keeping them in lock-step.

    When in doubt, use embedded documentation.

    The `doc/graphics` subdirectory holds JPEGs and SVGs displayed
    inline within wiki articles.

*   <b>`etc`</b> — Files which get copied to `/etc` or one of its
    subdirectories at installation time.

    There is an exception: `pidp8i.service.in` does not get installed to
    `/etc` at install time, but only because systemd’s [unit file load
    path scheme][uflp] is screwy: *some* unit files go in `/etc`, while
    others do not. The systemd docs claim we can put user units in
    `/etc/systemd/user` but this does not appear to work on a Raspberry
    Pi running Raspbian Stretch at least. We’ve fallen back to another
    directory that *does* work, which feels more right to us anyway, but
    which happens not to be in `/etc`. If systemd were designed sanely,
    we’d install such files to `$HOME/etc/systemd` but noooo…

    Since none of the above actually argues for creating another
    top-level repository directory to hold this one file, we’ve chosen
    to store it in `etc`.

*   <b>`examples`</b> — Example programs for the end user’s edification.
    Many of these are referenced by documentation files and therefore
    should not be renamed or moved, since there may be public web links
    referring to these examples.

*   <b>`hardware`</b> — Schematics and such for the PiDP-8/I board or
    associated hardware.

*   <b>`labels`</b> — Graphics intended to be printed out and used as
    labels for removable media.

*   <b>`lib`</b> — Library routines used by other programs, installed to
    `$prefix/lib`.

*   <b>`libexec`</b> — A logical extension of `lib`, these are
    standalone programs that nevertheless are intended to be run
    primarily by other programs. Whereas a file in `lib` might have its
    interface described by a programmer’s reference manual, the
    interface of a program in `libexec` is described by its usage
    message.

    Currently, there is only one such program, `scanswitch`, which si
    run primarily by `etc/pidp8i`. It is only run by hand when someone
    is trying to debug something, as in development.

    Programs in `libexec` are installed to `$prefix/libexec`, which is
    *not* put into the user’s `PATH`, on purpose. If a program should
    end up in the user’s `PATH`, it belongs in `bin`. Alternately, a
    wrapper may be put in `bin` which calls a `libexec` program as a
    helper.

*   <b>`media`</b> — Binary media images used either by SIMH directly or
    inputs consumed by tools like `os8-run` to *produce* media used by
    SIMH.

    The contents of this tree are installed to `$prefix/share/media`.

*   <b>`obj`</b> — Intermediate output directory used by the build
    system. It is safe to remove this directory at any time, as its
    contents may be recreated by `make`. No file checked into Fossil
    should be placed here.

    (Contrast `bin` which does have some files checked into Fossil; all
    of the *other* files that end up in `bin` can be recreated by
    `make`, but not these few hand-written programs.)

*   <b>`scripts`</b> — Scripts driving `os8-run`, most of which are
    invoked by the build system, though some are meant to be run by
    hand, such as the content of `scripts/test`.

*   <b>`src`</b> — Source code for the project’s programs, especially
    those that cannot be used until they are built. The great majority
    of these programs are written in C. The build system’s output
    directories are `bin`, `boot`, `libexec`, and `obj`.

    Programs that can be used without being “built,” example programs,
    and single-file scripts are placed elsewhere: `bin`, `examples`,
    `libexec`, `tools`, etc. Basically, we place such files where the
    build system *would* place them if they were built from something
    under `src`.

    This directory also contains PDP-8 source files of various sorts,
    mainly those used for building the SIMH media and the `os8pkg`
    packages. These are all “built” into other forms that then appear
    when running the simulator, rather than being used directly in this
    source code form.

    There are no program sources in the top level of `src`. The file
    `src/config.h` may appear to be an exception to that restriction,
    but it is *generated output* of the `configure` script, not “source
    code” *per se*.

    Multi-module programs each have their own subdirectory of `src`,
    each named after the program contained within.

    Single module programs live in `src/misc` or `src/asm`, depending on
    whether they are host-side C programs or PAL8 assembly programs.

*   <b>`test`</b> — Output directory used by `tools/test-*`.

*   <b>`tools`</b> — Programs run only during development and not
    installed.

    If a program is initially created here but we later decide that it
    should be installed for use by end users of the PiDP-8/I system, we
    move it to either `bin` or `libexec`, depending on whether it is run
    directly at the command line or run from some other program that is
    also installed, respectively.

[edoc]:  https://fossil-scm.org/home/doc/trunk/www/embeddeddoc.wiki
[fset]:  https://fossil-scm.org/home/doc/trunk/www/settings.wiki
[fscmd]: https://fossil-scm.org/home/help?cmd=setting
[uflp]:  https://freedesktop.org/software/systemd/man/systemd.unit.html#id-1.9


## <a id="patches"></a> Submitting Patches

If you do not have a developer login on the project repository, you can
still send changes to the project.

The simplest way is to say this after developing your change against
trunk:

    $ fossil diff > my-changes.patch

Then paste that into a [forum post][pfor] using a [fenced code
block][fcb]. We will also accept trivial patches not needing discussion
as text or attachments on [a Fossil ticket][tkt].

If you're making a patch against a PiDP-8/I distribution tarball, you can
generate a patch this way:

    $ diff -ruN pidp8i-olddir pidp8i-newdir > mychange.patch

The `diff` command is part of every Unix and Linux system, and should be
installed by default. If you're on a Windows machine, GNU diff is part
of [Cygwin](http://cygwin.com/) and [WSL]. Fossil is also available for
all of these systems. There are no excuses for not being able to make
unified diffs. :)

[fcb]: https://www.markdownguide.org/extended-syntax#fenced-code-blocks
[tkt]: https://tangentsoft.com/pidp8i/tktnew
[WSL]: https://docs.microsoft.com/en-us/windows/wsl/install-win10


#### Bundles Instead of Patches

If your change is more than a small patch, `fossil diff` might not
incorporate all of the changes you have made. The old unified `diff`
format can’t encode branch names, file renamings, file deletions, tags,
checkin comments, and other Fossil-specific information. For such
changes, it is better to send a [Fossil bundle][fb]:

    $ fossil set autosync 0                # disable autosync
    $ fossil checkin --branch my-changes
      ...followed by more checkins on that branch...
    $ fossil bundle export --branch my-changes my-changes.bundle

After that first `fossil checkin --branch ...` command, any subsequent
`fossil ci` commands will check your changes in on that branch without
needing a `--branch` option until you explicitly switch that checkout
directory to some other branch. This lets you build up a larger change
on a private branch until you’re ready to submit the whole thing as a
bundle.

Because you are working on a branch on your private copy of the
project’s Fossil repository, you are free to make as many checkins as
you like on the new branch before giving the `bundle export` command.

Once you are done with the bundle, upload it somewhere public and point
to it from a forum post or ticket.

[fb]: https://fossil-scm.org/home/help?cmd=bundle


#### Contribution Licensing

Submissions should include a declaration of the license you wish to
contribute your changes under. We suggest using the [SIMH license][simhl],
but any [non-viral][viral] [OSI-approved license][osil] should suffice.
We’re willing to tolerate viral licenses for standalone products; for
example, CC8 is under the GPL, but it’s fine because it isn’t statically
linked into any other part of the PiDP-8/I software system.

[osil]:  https://opensource.org/licenses
[simhl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
[viral]: https://en.wikipedia.org/wiki/Viral_license


#### <a id="ghm"></a> Can I Use GitHub Instead?

Although the PiDP-8/I project does have a [GitHub mirror][ghm], it is
intended as a read-only mirror for those heavily tied into Git-based
tooling. You’re welcome to send us a PR anyway, but realize that what’s
going to happen on the back end is that we’ll generate a patch, apply it
to the Fossil repo by hand, test it, and then commit it to the
repository under one of our existing Fossil developer accounts. Only
then do we update the mirror so that the change appears on GitHub; thus,
you don’t get GitHub credit for the PR. You avoid these problems by
simply asking for a developer account on the Fossil repo, so you can
commit there instead.

This is not simply because setting up bidirectional mirroring is
difficult, it is actually [impossible to achieve 100% fidelity][ghlim]
due to limitations of Git and/or GitHub. If you want a faithful clone of
the project repo, or if you wish to contribute to the project’s
development with full credit for your contributions, it’s best done via
Fossil, not via GitHub.

[ghlim]: https://fossil-scm.org/home/doc/trunk/www/mirrorlimitations.md
[ghm]:   https://github.com/tangentsoft/pidp8i/


## <a id="code-style"></a> The PiDP-8/I Software Project Code Style Rules

Every code base should have a common code style. Love it or
hate it, here are PiDP-8/I’s current code style rules:

**C Source Code**

File types: `*.c`, `*.h`, `*.c.in`

We follow the SIMH project’s pre-existing code style when modifying one
of its source files:

*   Spaces for indents, size 4; tabs are rendered size 8 in HTML output,
    since that’s how a PDP-8 terminal would likely interpret it!

*   DOS line endings. (Yes, even though this is a Linux-based project!
    All decent Linux text editors can cope with this.)

*   Function, structure, type, and variable names are all lowercase,
    with underscores separating words

*   Macro names are in `ALL_UPPERCASE_WITH_UNDERSCORES`

*   Whitespace in the SIMH C files is of a style I have never seen
    anywhere else in my decades of software development. This example
    shows the important features:

    ```C
    int some_function (char some_parameter)
    {
    int some_variable = 0;

    if (some_parameter != '\0') {
        int nbytes = sizeof (some_parameter);
        char *buffer = malloc (4 * nbytes);

        switch (some_parameter) {
            case 'a':
                do_something_with_buffer ((char *)buffer); 
            default:
                do_something_else ();
            }
        }
    else {
        some_other_function (with_a_large, "number of parameters",
            wraps_with_a_single, "indent level");
        printf (stderr, "Failed to allocate buffer.\n");
        }
    }
    ```

    It is vaguely like K&R C style except that:

    *   The top level of statements in a function are not indented

    *   The closing curly brace is indented to the same level as the
        statement(s) it contains

    *   There is a space before all opening parentheses, not just those
        used in `if`, `while`, and similar flow control statements.

        Nested open parentheses do not have extra spaces, however. Only
        the outer opening parenthesis has a space separating it from
        what went before.

    *   Multiple variables declared together don’t have their types and
        variable names aligned in columns.

    I find that this style is mostly sensible, but with two serious problems:
    I find the indented closing curly braces confusing, and I find that the
    loss of the first indent level for the statements inside a function makes
    functions all visually run together in a screenful of code. Therefore,
    when we have the luxury to be working on a file separate from SIMH,
    we use a variant of its style with these two changes, which you can
    produce with the `tools/restyle` command. See its internal comments for
    details.

    That gives the following, when applied to the above example:

    ```C
    int some_function (char some_parameter)
    {
        int some_variable = 0;

        if (some_parameter != '\0') {
            int nbytes = sizeof (some_parameter);
            char *buffer = malloc (4 * nbytes);

            switch (some_parameter) {
                case 'a':
                    do_something_with_buffer ((char *)buffer); 
                default:
                    do_something_else ();
            }
        }
        else {
            some_other_function (with_a_large, "number of parameters",
                wraps_with_a_single, "indent level");
            printf (stderr, "Failed to allocate buffer.\n");
        }
    }
    ```

    If that looks greatly different, realize that it is just two indenting
    level differences: add one indent at function level, except for the
    closing braces, which we leave at their previous position.

    SIMH occasionally exceeds 100-column lines. I recommend breaking
    long lines at 72 columns. Call me an 80-column traditionalist.

    When in doubt, mimic what you see in the current code. When still in
    doubt, ask on the [project forum][pfor].

[indent]: http://linux.die.net/man/1/indent


**Plain Text Files**

File types: `*.md`, `*.txt`

*   Spaces for indents, size 4.

*   Unix line endings. The only common text editor I’m aware of that
    has a problem with this is Notepad, and people looking at these
    files anywhere other than unpacked on a Raspberry Pi box are
    probably looking at them through the Fossil web interface on
    tangentsoft.com.

*   Markdown files must follow the syntax flavor understood by
    [Fossil’s Markdown interpreter][fmd].

[fmd]: https://tangentsoft.com/pidp8i/md_rules


## <a id="tickets"></a> Ticket Workflow

Normal end users of the Fossil ticket system are not expected to
understand it properly or to fill out tickets properly. Without certain
permissions, it is in fact not possible to completely fill out a ticket
properly. Project developers typically must triage, augment, and correct
submissions from the start.

Here’s the basic workflow for a “code defect” ticket, colloquially
called a bug report:

``` pikchr toggle indent
      fill = bisque
      linerad = 15px

      define diamond { \
        box wid 150% invis
        line from last.w to last.n to last.e to last.s close rad 0 $1
      }

      oval "SUBMIT TICKET" width 150%
      down
      arrow 50%
NEW:  file "New bug ticket" "marked \"Open\"" fit
      arrow same
      box "Triage," "augment &" "correct" fit
      arrow same
DC:   box "Developer comments" fit
      arrow same
FR:   box "Filer responds" fit
      arrow 100%
REJ:  diamond("Reject?")
      right
      arrow 100% "Yes" above
      box "Mark ticket" "\"Rejected\" &" "\"Resolved\"" fit with .w at previous.e
      arrow right 50%
REJF: file "Rejected" "ticket" fit
      arrow right 50%
REOP: diamond("Reopen?")
      down
REJA: arrow 75% from REJ.s "  No; fix it" ljust
CHNG: box "Developer changes code" with .n at last arrow.s fit
      arrow 50%
FIXD: diamond("Fixed?")
      right
FNO:  arrow "No" above
RES:  box "Optional:" "Update ticket resolution:" "\"Partial Fix\", etc." fit
      down
      arrow 75% "  Yes" ljust from FIXD.s
      box "Mark ticket" "\"Fixed\" & \"Closed\"" fit
      arrow 50%
RESF: file "Resolved ticket" fit
      arrow same
      oval "END"

      line from 0.3<FR.ne,FR.se> right even with 0.25 right of DC.e then \
          up even with DC.e then to DC.e ->

      line from NEW.w left 0.5 then down even with REJ.w then to REJ.w ->
      line invis from 2nd vertex of last line to 3rd vertex of last line \
          "fast reject path" above aligned

      line from RES.e right 0.3 then up even with CHNG.e then to CHNG.e ->

      line from REOP.s "No" aligned above down 0.4
      line from previous.s down to (previous.s, RESF.e) then to RESF.e ->

      line from REOP.n "Yes" aligned below up 0.3
      line from previous.n up even with 0.6<FR.ne,FR.se> then to 0.6<FR.ne,FR.se> ->
```

On noticing a new-filed ticket — such as because you are subscribed to
email notifications on ticket changes — someone with sufficient
privilege triages it, sets values for the fields not exposed to the
ticket’s filer, and fixes up any incorrect values given in the initial
submission.

The Status of a ticket initially starts out as Open; the filer cannot
change that default value, short-circuiting the process. If the person
triaging a ticket takes the time to check that the bug actually occurs
as the ticket filer claims, the Status should change to Verified.

If a developer implements a fix in response to a ticket, he
has two choices: change the ticket’s Status to “Review” if he wants
someone to check out the change before closing it, or go straight to
Closed status. Closing a ticket hides it from the [Wishes] and [Bugs] ticket
reports.

The process for software feature request and documentation improvement
request tickets is essentially the same, differing mainly in terminology
rather than process flow: instead of verifying the existence of a bug,
the one triaging the ticket verifies that the feature does in fact not
exist yet, and so on.

A common requrement in larger teams is that all ticket changes to go through Review
status before getting to Closed, but the PiDP-8/I project is too small
to require such ceremony: if we’ve given you a developer account on the
repository, you’re expected to resolve and close tickets in the same
step, most of the time. If you cannot confidently close a ticket when
resolving it, you should probably not be assigning a resolution yet
anyway. Do whatever you have to with tests and such to *become* certain
before you resolve a ticket.

There is a process interlock between the Resolution and Status settings
for a ticket: while Status is not Closed, Resolution should be Open.
When Resolution changes from Open, Status should change to either Review
or, preferentially, Closed. A resolution is an end state, not an
expression of changeable intent: no more ceremony than setting a
ticket’s Resolution state *away* from Open and its Status *to* Closed is
required.

If you do not intend to close a ticket but wish to advocate for a
particular resolution, just add a comment to the ticket and let someone
else choose whether to close the ticket or not. Don’t change the
Resolution value until the issue has been *resolved* for good.

For example, the resolution “Works as Designed” does not merely mean,
“Yes, we know it works that way,” it also implies “…and we have no
intention to change that behavior, ever.” If there is a chance that the
behavior described in the ticket could change, you should not assign any
resolution. Just leave it open until someone decides to do something
final with the ticket.

This is not to say that a ticket can never be re-opened once it’s had a
resolution assigned and been closed, but that this is a rare occurrence.
When a developer makes a decision about a ticket, it should be difficult
to re-open the issue. A rejected ticket probably shouldn’t be re-opened
with anything short of a working patch, for example:

> User A: I want feature X.

> Dev B: No, we’re not going to do that. Ticket closed and rejected.

> User C: Here’s a patch to implement feature X.

> Dev B: Well, that’s different, then. Thanks for the patch! Ticket
> marked Implemented, but still Closed.

[Bugs]:   https://tangentsoft.com/pidp8i/bugs
[Wishes]: https://tangentsoft.com/pidp8i/wishes


## License

Copyright © 2016-2020 by Warren Young. This document is licensed under
the terms of [the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
