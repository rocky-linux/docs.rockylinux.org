---
title: 'Overview of the ssh-keygen utility'
author: 'Hayden Young <hi@hbjy.dev>'
---

The ssh-keygen utility is used for generating keys. It does this by using one of three different digital signature algorithms.

## Key Formats

Some sample key formats that ssh-keygen supports are:

- RSA
- DSA
- ECDSA

## Creating SSH Keys

To generate a 521 bits long ecdsa key type the following commands while logged in at your terminal.

1. Create the .ssh folder under your home directory, if it doesn't exist already, run: `mkdir  ~/.ssh`
2. Set the proper permissions for the folder you just created with `chmod  -R 700  ~/.ssh`
3. Use the ssh-keygen utility to create a new set of keys named "my-rocky-key-ecdsa*".

<!-- TODO: Implement tl;dr feature -->
<!--
<TLDR>
```
$ ssh-keygen -f   ~/.ssh/my-rocky-key-ecdsa -t ecdsa -b 521
```
</TLDR>
-->
