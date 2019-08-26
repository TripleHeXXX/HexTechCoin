#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

HEXTECHCOIND=${HEXTECHCOIND:-$SRCDIR/hextechcoind}
HEXTECHCOINCLI=${HEXTECHCOINCLI:-$SRCDIR/hextechcoin-cli}
HEXTECHCOINTX=${HEXTECHCOINTX:-$SRCDIR/hextechcoin-tx}
HEXTECHCOINQT=${HEXTECHCOINQT:-$SRCDIR/qt/hextechcoin-qt}

[ ! -x $HEXTECHCOIND ] && echo "$HEXTECHCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
HXTCVER=($($HEXTECHCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$HEXTECHCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $HEXTECHCOIND $HEXTECHCOINCLI $HEXTECHCOINTX $HEXTECHCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${HXTCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${HXTCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
