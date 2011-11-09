# Twostroke

Twostroke is a Javascript implementation written in **pure Ruby**. It currently consists of:

* A parser (which works, but is in need of an overhaul)
* Two compilers:
  * One that targets Javascript, perfect for obfuscation
  * And another that targets TSASM - Twostroke's internal bytecode format
* A VM that runs TSASM bytecode
* A minimal Javascript standard library implementation (also in need of some love)
* A test suite containing:
  * Some tests written for Twostroke
  * Underscore.js's complete test suite (minus the cases relying on the DOM)
  
# Why use Twostroke?

### It's cool:

![repl](http://i.imgur.com/HsFB0.gif)

### It actually works:

yep, that's **unmodified** underscore.js:

![tests lol](http://i.imgur.com/L4aUQ.png)