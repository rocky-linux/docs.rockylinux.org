---
title: 'Overview of the ssh-keygen utility'
---

The ssh-keygen utility is used for generating keys. It does this by using one of three different digital signature algorithms.

## Key Formats

Some sample key formats that ssh-keygen supports are:

- RSA
- DSA
- ECDSA

## Creating SSH Keys

To generate a 521 bits long ecdsa key type the following commands while logged in at your terminal.

Create the .ssh folder under your home directory, if it doesn't exist already.

```shell
$ mkdir  ~/.ssh
```

Then, set the proper permissions for the folder you just created.

```shell
$ chmod -R 700 ~/.ssh
```

Finally, use the ssh-keygen utility to create a new keypair. It is optional, but _strongly_ recommended,
that you set a password on this SSH key. The ssh-keygen command will prompt you for this.

```shell
$ ssh-keygen -f ~/.ssh/my-rocky-key-ecdsa -t ecdsa -b 521`
Generating public/private ecdsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/user/.ssh/my-rocky-key-ecdsa
Your public key has been saved in /home/user/.ssh/my-rocky-key-ecdsa.pub
The key fingerprint is:
SHA256:FhcZiUJqmcOlIVGemT6kEWEAc34tiN1gmIJfB6yUcJk user@hostname
The key's randomart image is:
+---[ECDSA 521]---+
|B=@O+oo  .o+     |
|=XEOo%o . o.     |
|oo=o^.... .      |
|  oB o   o       |
|  . o   S        |
|     . .         |
|                 |
|                 |
|                 |
+----[SHA256]-----+
```

Now, if you look in the `~/.ssh` directory, you should see two files.

```shell
$ ls ~/.ssh
my-rocky-key-ecdsa my-rocky-key-ecdsa.pub
```

For the majority of services that require SSH authentication, you'll need to give them
your _public_ key. This is the file with the `.pub` extension, _not_ the one without it.
That one is your _private_ key and you should never share it.

```shell
$ cat ~/.ssh/my-rocky-key-ecdsa.pub
ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACZazN6WMOhQHVJ9Q1mxG/ji1hF/xcgqHphAmDZ8r0qV4PQgL0VctjlWkm3t2UwcSSYw5GJRRgi6rqbYVC3s41jAQH7gFJDKtBhIh8MQT8u0dAUBz8B4imeKt4N8BASSu7hg4ECPjZNkwAW677Li6hcviglkr74Svbb7II9lLWjHRDfjA== user@hostname
```

<!-- TODO: Implement tl;dr feature -->
<!--
<TLDR>
```
$ ssh-keygen -f   ~/.ssh/my-rocky-key-ecdsa -t ecdsa -b 521
```
</TLDR>
-->
