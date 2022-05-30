# Throttling the Simulator

When you do not give the `--throttle` option to the `configure` script,
the simulator's speed is set based on the number of CPU cores detected
by the `tools/corecount` script.


## <a id="mcore"></a>Multi-Core Default

If `corecount` detects a multi-core system, the default behavior is to
not throttle the simulator at all, since there are only 2 threads in the
software that take substantial amounts of CPU power.

The most hungry thread is the PDP-8 simulator proper, which runs flat-out,
taking an entire core's available power by default.

The other hungry thread is the one that drives the front panel LEDs,
which takes about 35% of a single core's power on a Raspberry Pi 3 when
you build the software with the incandescent lamp simulator enabled.

This leaves over 2 cores worth of CPU power untapped on multi-core
Raspberry Pis, so the system performance remains snappy even with the
simulator running.

You can force this behavior with `--throttle=none`.


## <a id="score"></a>Single-Core Default

If the `configure` script decides that you're building this on a
single-core system, it purposely throttles the PDP-8 simulator so that
it takes about 50% of a single core's worth of power on your system.

Since different single-core Raspberry Pi boards run at different clock
rates, we cannot just set the instructions per second (IPS) rate to a
fixed value and know that it's correct.

We could choose a value low enough that it's supposed to work
everywhere, but there's a serious problem with that. SIMH's reaction to
not having enough host CPU power to run at the requested IPS rate is to
*turn off throttling entirely*, thus hogging the whole host CPU, exactly
the opposite of what you want by turning on throttling! Host CPU power
is sapped during boot time, the point where the PiDP-8/I software
normally starts up. That badly throws off SIMH's estimates of the
hardware's capability, do you might get thrown into no-throttle mode
even if the hardware could actually achieve the requested IPS rate once
it has the CPU mostly to itself.

Our chosen solution to all of these problems is `set throttle 50%`,
which tells SIMH to dynamically adjust the IPS rate according to
available host CPU power. This does mean you don't get a steady IPS
rate, but it does enforce our wish to leave some CPU power left over for
background tasks.

(There's [an alternate fix for this](#stabilization) in recent
versions.)

You might wish to adjust that default host/simulator CPU usage split.
The `--throttle` option accepts percentages:

     ./configure --throttle=75%

This throttling feature does not allow a single-core Pi to run the
[incandescent lamp simulator][ils]. We've tried, and you have to clock
the simulator down to less than the speed of a PDP-8/S to leave enough
CPU power for the ILS to run properly! (DEC says the "S" refers to the
serial bit handling path in this cost-reduced version of the original
PDP-8, but everyone else knows the "S" stands for *SSSLLLOOOOWWW*.) We
have ideas for ways to improve the speed of the ILS which may allow
the PDP-8 simulator to run at a reasonable rate alongside the ILS,
but these plans may never make their way off the wish list, or they may
not succeed if they are implemented.  For this reason, the build system
disables the incandescent lamp simulator feature on a single-core Pi.

You can force the build system to select this throttle value even on a
multi-core Pi with `--throttle=single-core`.

You will erroneously get this single-core behavior if you run the
`configure` script on a system where `tools/corecount` has no built-in
way to count the CPU cores in your system correctly, so it returns 1,
forcing a single-core build.  That script currently only returns the
correct value on Linux, BSD, and macOS systems.  To fix it, you can
either say `--throttle=none` or you can patch `tools/corecount` to
properly report the number of cores on your system.  If you choose the
latter path, please send the patch to the mailing list so it can be
integrated into the next release of the software.


## <a id="under"></a>Underclocking

There are many reasons to make the software run slower than it normally
would.  You may achieve such ends by giving the `--throttle` option to
the `configure` script:

*   `--throttle=CPUTYPE`: if you give a value referencing one of the
    many PDP-8 family members, it selects a value based on the execution
    time of a `TAD` instruction in direct access mode on that processor:

    | Value            | Alias For | Memory Cycle Time
    ---------------------------------------------------
    | `pdp8e`          | 416k      | 1.2 µs
    | `pdp8i`, `pdp8a` | 333k      | 1.5 µs
    | `pdp8l`, `pdp8`  | 313k      | 1.6 µs
    | `ha6120`         | 182k      | 2.7 µs
    | `im6100a`        | 200k      | 2.5 µs
    | `im6100`         | 100k      | 5 µs
    | `im6100c`        | 83k       | 6 µs
    | `pdp8s`          | 63k       | 8 µs

    I chose `TAD` because it's a typical instruction for the processor,
    and its execution speed is based on the memory cycle time for the
    processor, an easy specification to find.  Other instructions (e.g.
    most OPR instructions) execute faster than this, while others (e.g.
    IOT) execute far slower.  (See the processor's manual for details.)

    SIMH, on the other hand, does not discriminate.  When you say
    `--throttle=pdp8i`, causing the build system to insert `SET THROTTLE
    333k` commands into the SIMH boot scripts, the SIMH PDP-8 simulator
    does its best to execute exactly 333,000 instructions per second,
    regardless of the instruction type.  Consequently, if you were to
    benchmark this simulator configured with one of the options above,
    there would doubtless be some difference in execution speed when
    compared to the original hardware, depending on the mix of
    instructions executed.

    (See the I/O Matters section below for a further complication.)

    The values for the Intersil and Harris CMOS microprocessors are for
    the fastest clock speed supported for that particular chip.  Use the
    `STRING` form of this option (documented below) if you wish to
    emulate an underclocked microprocessor.

*   `--throttle=human`: Causes the computer to throttle the human.

    "I'm sorry, Dave, but you are not worthy to run this software."

    "Aaackkthhhpptt..."

    No, wait, that can't be right.
    
    Let's see here...ah, yes, what it *actually* does is slows the
    processor down to 10 instructions per second, about the fastest that
    allows the human eye to easily discern LED state changes as
    separate.  If you increase it very much above this, the eye starts
    seeing the LED state changes as a blur.

    This mode is useful for running otherwise-useful software as a
    "blinkenlights" demo.

    This mode disables the incandescent lamp simulator (ILS); see below.

*   `--throttle=trace`: Runs one instruction per second.  The effect is
    as if you were running a PDP-8/I in single-instruction mode and were
    pressing the `CONT` button once a second to step through a program.

    This mode also disables the ILS.

*   `--throttle=STRING`: any value not otherwise understood is passed
    directly to SIMH in `SET THROTTLE` commands inserted into the
    generated `boot/*.script` files.  You can use any string here that
    SIMH itself supports; [read the fine manual][tfm].

    If you use the ratio form here (e.g. `--throttle=123/456`) the
    configuration script disables the ILS feature because of the way
    SIMH handles this type of timing.  The ratio form of CPU throttling
    tells SIMH to run some number of instructions and then sleep for
    some number of milliseconds.  (The above 123/456 example means "run
    123 instructions, then sleep for 456 ms.")  This batched instruction
    execution scheme interferes with the high-speed LED panel update
    rate, so we must disable the ILS when running with such a throttle
    value set.

    Therefore, you should only use the ratio form of throttle value when
    you need to get under 1000 instructions per second.  For any value
    over that, give `--throttle=1k` or higher, which allows the ILS
    feature to properly maintain its LED brightness values.


## <a id="stabilization"></a>Throttle Stabilization

After the 2017.12.22 release, the [upstream SIMH v4 project][simh]'s
main developer [changed the way throttling is handled][si508], mostly
for the better. The primary upshot of this change — from the perspective
of this document's subject matter — is that the simulator doesn't make
any decisions about whether your requested throttle value is plausible
until some seconds after the simulator starts.

The SIMH default for this is 20 seconds, since the default must work for
all simulators in the SIMH family, some of which have long bootup
cycles. 20 seconds is far too long for a PDP-8, which boots instantly,
so we've overridden that in the stock `boot/*.script` files, setting the
throttle calibration delay to 3 seconds in order to give the SIMH timing
code a sufficiently long baseline to work from.

If you have a prior installation of the PiDP-8/I software, your boot
scripts will not have this change unless you have taken specific steps
to achieve it, so you will be using the 20-second SIMH default! See
"[Overwriting the Local Simulator Setup][olss]" in the top-level
`README.md` file for your options here.

For those first seconds, the simulator runs *unthrottled*, after which
the SIMH core timing code looks at the number of instructions executed
during that time and then determines from that what timing values it
needs to use to achieve your requested throttle value. It also checks
whether the throttle value is even possible at this time.

There is one case where we anticipate that you might want to increase
this value: you've set a fixed throttle value that is right near the
host CPU's ability to achieve and you have the simulator set to start at
host boot time, so that there are lots of processes starting up and
initializing in parallel with the PiDP-8/I simulator. In that case, you
might want to override the following line in `boot/*.script`, setting a
long enough value for the system load to stabilize:

    deposit int-throttle THROT_DELAY 15

That would override the 20-second stabilization time default to 15
seconds.

[olss]:  https://tangentsoft.com/pidp8i/doc/trunk/README.md#overwrite-setup
[simh]:  https://github.com/simh/simh/
[si508]: https://github.com/simh/simh/issues/508


## <a id="io"></a>I/O Matters

The throttle mechanism discussed above only affects the speed of the
PDP-8 CPU simulator. It does not affect the speed of I/O operations.

The only I/O channel you can throttle in the same way is a serial
terminal by purposely choosing a slower bit rate for it than the
maximum value.  If you set it to 110 bps, it runs at the speed of a
Teletype Model 33 ASR, the most common terminal type used for the
PDP-8/I, and most other early PDP-8 flavors. Later in the PDP-8's
commercial life, faster glass terminals became available, though
it was not always possible to use them at their maximum data rate,
due to the primitive nature of I/O handling in those days.

I'm not aware of a way to make SIMH slow the other I/O operations, such
as disk access speeds, in order to emulate the speed of the actual
hardware.


## License

Copyright © 2017-2018 by Warren Young. This document is licensed under
the terms of [the SIMH license][sl].

[sl]:  https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
[ils]: https://tangentsoft.com/pidp8i/wiki?name=Incandescent+Lamp+Simulator
[tfm]: https://tangentsoft.com/pidp8i/uv/doc/simh/main.pdf
