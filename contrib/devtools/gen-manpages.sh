#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

FRANCD=${FRANCD:-$BINDIR/francd}
FRANCCLI=${FRANCCLI:-$BINDIR/franc-cli}
FRANCTX=${FRANCTX:-$BINDIR/franc-tx}
FRANCQT=${FRANCQT:-$BINDIR/qt/franc-qt}

[ ! -x $FRANCD ] && echo "$FRANCD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
FRCVER=($($FRANCCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for francd if --version-string is not set,
# but has different outcomes for franc-qt and franc-cli.
echo "[COPYRIGHT]" > footer.h2m
$FRANCD --version | sed -n '1!p' >> footer.h2m

for cmd in $FRANCD $FRANCCLI $FRANCTX $FRANCQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${FRCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${FRCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
