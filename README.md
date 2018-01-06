# SCB-to-TSV
Converts Standard Chartered Bank (India) E-statements to tilde separated values.

## Prerequisites

* bash
* gnused as gsed on `PATH`
* ghostscript as gs on `PATH`

## How to use

1. Clone this repository
1. Create directory called `pdf` in the repository
1. Copy all the estatements in the `pdf`directory
1. Run `./go.sh` from the root of the repository
1. You'll find the cleaned up data in a file called `final`

## Why tilde?

Because... I don't know really. Maybe because I like the way it flows ~~~~~.
But if you like commas you run this after `go.sh`:

```bash
gsed -i 's|~|,|g' final
```
