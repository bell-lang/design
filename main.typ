#import "template.typ": *

#let minecraft = "Minecraft™"
#let minecraft_java_edition = "Minecraft: Java Edition™"

#show: project.with(
  title: "The design of the Bell programming language",
  authors: (
    (name: "Yoav Grimland", email: "mailbox@miestro.de"),
  ),
  abstract: "The Bell programming language is a language designed to be compiled into " + minecraft_java_edition + " commands, in essence data packs. This paper then serves as an informal reference of the language's syntax, semantics, and behavior. Not every single feature is documented here, but only what is relevant for the development of the language's compiler by the writer of this paper, Yoav Grimland, current maintainer of that project. Among things detailed there is a specification of Bell's type system, Bell's program semantics and Bell's module system. Syntax is also a part of this paper, but the syntax here isn't comprehensive, at all.",
  date: "June 12, 2023",
)


= Introduction
Ever since #minecraft version 1.4.2, players have been able to impact their worlds in ways impossible before, constrained to the basic, physical rules of the game, but not of it's gameplay. Command blocks, the item added, allow players to run commands, somewhat similar in look to terminal commands, "automatically". Instead of manually inserting commands, they were able to integrate them into their worlds. However for many applications this simply practical, or even enough and so in 1.13, map-makers, creators and players alike were given the ability to create data packs. Data packs are made up of a collection of files (`.mcfunction`), where every file is a "function" (a procedure). The functions contain sequences of commands, and may call other such functions. Additionally, a data pack designates a special function to be run when the data pack is loaded (for example, for initialization) and another for each game tick (one twentieth of a second). Datapacks are highly flexible for all sorts of use-cases, and have been widely adopted by the community. For example, today, little maps are created without them. Despite this, data packs are not perfect, as many know by experience.

== The problem with data packs
As anyone who has ever tried programming with a shell's scripting language will know, it isn't a pleasant ride - sure, you can get things done, but at what cost? Glorious examples of this, such as bash's infamous `if` and `fi`, or fish's non-strict script evaluation (continuing after an error implicity, which is never a good idea) are all too common, and are shared by many scripting languages (the examples here are not the only scripting languages with these "features").

Whilst data packs aren't strictly speaking shell scripts, they certainly started like them, and are in many ways, worse, and not better. Data packs don't feature advanced, or structural control flow, no parameters, a very non-robust "variable" system for _integers_ amongst many other flaws. The kind of features one would expect of a modern programming language simply aren't present in them. There is no good built-in way to create and manipulate records, proper functions, tagged unions, _lists and strings_ and many more. Despite this, data packs at least do stop on error, or rather don't really have much of an error system besides syntax errors, that deny the data pack running rights.

As one can guess, using a programming language this is not easy - in fact it's the opposite of easy, it's hard. Only after using several disjointed game mechanics, involving among other things the game's log were players able to actually use "strings", or to be more accurate, "string parsing", which essentially allows one to turn a "string" to a character array, which one can work with "more easily" in their creations.

Unfortunately, "Vanilla" data pack alternatives, have to use dat packs under the hood. They only act as an abstraction layer, and so for example, no language may have an API for obtaining player name's as strings, and then manipulating these strings in real time, that is faster than what can be achieved today using string parsing, no language may have an API for handling payments in a #minecraft world (currently), as that is currently impossible using regular data packs, and so on. However, this doesn't mean these abstraction layers are useless, and to more precisely understand their offerring, we will review some of them.

== Solutions so far
All abstraction layers covered here work in relatively simple fashion - they compile ahead of time to a #minecraft data pack, which the users can then place in their data pack folder to run in game. The way this occurs, the interface for doing so and complexity of the data pack generated are the main differentiators between the different abstraction layers. Different people have different approaches for how this should be done, from people who believe the abstraction layers should be "in the spirit" of commands, and remain similar to them, whilst only adding shortcuts, a few custom commands and more of the like, to people who think a proper, general-purpose programming language is needed as the abstraction layer, that just has some semantic relation to the command language (also known as MCfunction), maybe via an a standard library, some primitives, or other things. Of course, these things lie on a spectrum, and the differences they cause will be studied here.

=== MC-BUILD
MC-BUILD mainly represents one end of the spectrum when it comes to #minecraft abstraction layers, and so it mostly a superset of MCfunction. It features a basic file-tree abstraction, allowing programmers to enjoy the benefits of directory-based organization without creating an unnavigable file-tree on the filesystem, a shortcut for creating functions (without parameters), function blocks, which act like anonymous functions and so on. For example, instead of creating a function like so:
```mcfunction
# In a.mcfunction
execute if score @s kills matches 100 run function example:b

# In b.mcfunction
say Hello
say World!
```
One can write:
```mcbuild
# In a.mcfunction
execute if score @s kills matches 100 run block {
  say Hello
  say World!
}
```
Which is both easier to read and follow through, and smaller. Overrall, MC-BUILD achieves its goals as a preprocessor very effectively. However, despite being the easiest to adopt, MC-BUILD ultimately doesn't solve the fundamental problems with MCfunction, only easing them. Despite this it does show the value of tight integration with the game and of easy adoptability - a language will likely not be used if it is not compatible with MCfunction. However, due to the fact pretty much all the languages compile to it, compatibility generally only requires a basic FFI system.

// TODO: Update description of this programming language, as it's built-in functions are quite expansive and deserve to be more closely mentioned. They aren't simple functions, but rather more keen to heavily-optionable macros
=== JMC
JMC is a bit contrary to MC-BUILD, in that it doesn't try to keep its syntax MCfunction-y. Despite this it still doesn't stray too far away from the MCfunction tradition. It allows for fully creating a data pack within the bounds of the language, by allowing one to specify `load` and `tick` time functions. It also features a standard library of useful functions, including ones for raycasting, random number generation, and a square root function, and some control-flow syntax. Despite this it's library is extremely small in comparison to any standard library of pretty much any language. Its "functions" are sadly mostly procedures (except built-in functions, which may take parameters of certain forms), but they allow for some convinience (inline procedures are still useful) and its variables are pretty much scoreboard members. In summary, it has little additional systems over MCfunction, does abstract away some details, allows for convinience and somewhat ditches MCfunction syntax. Still, one can easily write #minecraft commands in JMC. JMC is certainly a useful tool, but it's fragmented syntax (it also for example has two ways to write comments, via `#` and `//`) doesn't do it any favors and again, it still doesn't combat MCfunction's fundamental design problems. Still, it is, like MC-BUILD, useful. We believe JMC's biggest strength is it's standard library, and it is certainly something some other languages lack.

=== Trident
Trident is the final language to be covered here that attempts to be an "extension" of MCfunction. As such, Trident projects are supposed to be stored in data packs, and Trident "functions", can be used easily alongside regular #minecraft functions. Trident however is also the most advanced and argueably, complete of the languages seen so far. It offers unparalleled editing support (via it's own editor, Trident UI), a collection of native libraries for compile-time work, and more. It includes a class system with overloading and inheritance, a way to create custom items and entities, parametrized functions, _proper variables_ and other features.

However, these nice features of Trident have one major caveat - most of them are at compile-time. Now, whilst they are still incredibly useful and greatly accelerate programmers' abilities for data pack creation, it also means that Trident still cannot do things regular MCfunction without libraries cannot, like represeting longs, or floating point numbers at runtime, and things like that. Still, Trident greatly excels in it's mapmaking features. The editing-support of Trident, alongside it's heavy compile-time work is something we want to see in Bell, in some form. Likewise a custom item and entity API (including player APIs) and so on are all things that Bell would benefit having.

The main issues we have with Trident are that it still uses scoreboards for variable management and provides no real good alternative to that, and it's project structure. Interoperability like this is nice, but Trident should'nt have to bend itself to MCfunction's archaic data pack format. A custom Trident format could have been used, alongside the compatibility format. Likewise of course, more runtime features would be useful.

=== Debris
The main inspiration for Old Bell was in fact this language. Debris is the first language in here not designed to keep close to MCfunction syntax, and in general MCfunction's features and code style. It is much closer to a "real" general-purpose programming language than to MCfunction and that is reflected both in it's syntax and its features. Debris supports actual functions with parameters, a module system, a type system and compile-time evaluation, variables and with all this abstraction allows for heavy optimiation, tuples and so on. Debris is "close" to perfection, however it's not quite there. Its compiler errors are currently very bad, or sometimes outright wrong, it needs a more comprehensive module and type system (formalization for example) and better type inference and it has no #minecraft command API that allows for performing safe game related things. For example, to get the number of ticks since dawn in a world, you'd need to write:
```debris
let time = execute("time query daytime");
```
However of course, Debris is still a work in progress, it's in a very early stage and so this is quite unfair towards it. Then again all projects here are a work in progress, of some form. Despite this, Debris has some underyling issues with it, that likely even later growth won't be able to fully address. It lacks important features like borrowing, and an ownership system (or an alternative to it that still uses explicit references), cannot support recursion in it's current compilation model, among other things, and so on.

For Bell, Debris highlights the importance of planning ahead for language design and of making a good #minecraft communication API. In its positive aspects it also highlights the many benefits structured programming and really just general-purpose language features bring to #minecraft mapmaking, and programming in general. For example, it is possible in Debris to draw a Mandelbrot set using just around 100 lines of code (and around 50 assuming the standard library supports fixed-point math).

=== MCX
Probably the most unique approach to creating an abstraction layer, MCX is a dependently-typed functional programming language, that just so happens to compile to MCfunction. Of course, some of what has been said here is false, and MCX was designed very closely to be a #minecraft\-oriented programming language. The main reason behind being dependently-typed is that dependent-typing, alongside the other benefits it brings for correctness and it's flexibility is simply very useful for optimizations, as it grants certain guarantees for objects which are instances of a given type. A more concrete (general, not relating to MCX) example may help. Assume you wish to iterate over an array of real numbers and print out their values, and then return another array with doubled values, knowing that it looks like `a = [r1, r2, r3, r4, r5, r6, r7]`, that is, you don't know the values you iterate over, but there are seven. We could describe the type of this array in a dependently-typed fashion, and say it is of type `Vec 7 Real`. We can now use iterators to do our bidding:
```
a' = a |> iter
       |> each print
       |> map 2 * _
       |> collect
```
What is the issue here? The issue here is that the type of our output `a'` would generally need to be `Vec Real`. In other words, we would lose our length indication and so performance - remember that we are mainly using dependent types so that we can represent the array as an efficient record at runtime. However using dependent typing, we are able to define the iterator functions to take a general dependently-typed vector and perform operations on it, conserving the length information. In that way as well, the iteration is a lot less expensive, since we know exactly how long it will take. Instead of checking every time if we can yield another element, we can just keep track of a counter. Additionally now at runtime branch prediction could also speed things up in this way, and more optimizations could be made. As for MCX being functional, it just happens to be the case that functional programming more fits with dependent typing.

Whilst that is all very impressive, We cannot consider MCX perfect of course. Among all the languages seen so far, it is likely the most unapproachable of them all and is unlikely to ever replace MCfunction by a significant amount. It also remains to be see if the functional programs written in it can be compiled into faster imperiative versions of themselves. We however remain very skeptical of that. Whilst we believe in the long run, functional programming languages (and not necessarily pure ones) will be able to reach higher performance than imperiative languages, right now that is far from the case. Considering regular programming languages with far more tools up their sleeves couldn't do it after many years makes me skeptical. Even so, advancements can occur at any day, and it takes only a single paper to demolish the performance ceiling.

Likewise, another issue with MCX's design, as a #minecraft\-first programming language is that due to it being a functional programming language, it may require boxing, and users of it will naturally have to perform more recursion, which is all that much slower to perform on #minecraft, primarily due to implementing call-stacks and dynamic fake players, which have to be done using NBT and the `data` command at this time. Boxing of course also provides overhead. Whilst it is the case that many cases of boxing can be statically removed, the fact is that the remaining cases aren't _explicit_. This is another major issue we have with traditional functional progamming languages being used for compilation into MCfunction. They simply aren't explicit enough in a space where explicitness may be required, due to the fact MCfunction already can be very slow to run in comparison to other programming languages. For simple projects, this may not be an issue, but for large-scale maps, performing many calculations, any form of slow-down like this should ideally be immediately implied by the program structure.

=== Beet (and frameworks in general)
TODO

=== Old Bell
The final programming language to review here, is the language which we will refer to as "Old Bell". Old Bell isn't an actual programming language, but rather a previous attempt of creating a programming language compiling to MCfunction, for developer productivity by Yoav Grimland. Here we will use the term "Old Bell" to refer both to the language's compiler, and the language itself. Unlike the version of Bell detailed in this article, Old Bell wasn't designed very carefully, or frankly well, and so has many issues with it.

It doesn't actually formalize a type system, but instead only kind of specifies it in the form a very limited type-checker, that cannot perform much inference, isn't recoverable, and so any error during the compilation pipeline causes compilation to halt, meaning that for example, only a single parsing error may be emitted by the compiler, even when there are multiple, contains no module system, and certainly not a well-thought-out one, has an improperly-designed IR, which doesn't allow for optimization and is non-trivial to emit MCfunction from, doesn't allow for any form of variables other than via scoreboards (so recursion is for example impossible), has no records or typeclasses and finally has no ownership and reference system (due to the former). It is overall limited and oddly-designed, it's syntax mainly inspired by Rust, but without some of the semantic choices justifying such a syntax. Despite all of this, it can still achieve some nice feats, showing once more that programming languages compiling to MCfunction can be immensely useful. For example, the following program implements a simple trial-division primality-checker:
```
fn primes(input: int) {
  let test = 2;
  let is_prime = true;

  while is_prime && test * test < input {
    if input % test == 0 {
      is_prime = false;
    } else {
      test = test + 1;
    }
  }

  is_prime
}
```

This program however also demonstrates some other shortcomings of Old Bell, in that it has no square root, or squaring function, and in fact a standard library or looping breaks (which is why the `is_prime` variable exists). Another striking issue is that the return type isn't actually required, and so need not be specified. For a language requiring the specification of parameter types (mainly as a technical limitation rather than a concrete choice), not requiring this is inconsistent and unproductive.

In summary, the main lesson we believe should be learned from Old Bell's failures, is that planning is key for programming language success.

// TODO: Add section about Beet and it's adoption, as it has grown mostly past the barriers set forth in this section
== Adoption
In relation to all of these programming languages, one of Bell's most important goals is adoptability, and being ultimately adopted. I other words, Bell should be both easily adoptable, but also be attractive enough to be adopted. In order to study how this should be achieved, we can look at the adoption of each language reviewed here, and attempt to infer fron that, and the language's design conclusions as to the matter at hand.

Of all languages mentioned here (not including tools such as Beet, which we don't exactly consider to be programming languages, but rather frameworks), JMC is likely the most used. We believe it is mainly because JMC is both:
- Mature enough for expansive usage. Even under development, JMC contains a feature set particularly useful for data pack development.
- Focused on adoptability, especially by beginners.
Firstly, as said before, almost any valid MCfunction program is also a valid JMC program (features such as variables do however make the general claim false) and secondly, JMC's syntax was designed from the start essentially to be simple to learn, despite not being necessarily cohesive. Another major point contributing to JMC's success is it's branding and documentation. The language has it's own website which simply describes it and it's use-cases, was published in respected and populated #minecraft command forums of discussion with a video explainer and has easy to understand documentation. The relative simplicity of the language also helps.

Most other programming languages however remain not very well adopted. This is likely because of their higher barrier-of-entry, reduced "advertisement" and or more incomplete state. Once these basic barriers change, a more detailed assessment could be made, perhaps with a poll, however at the moment this is far from easy.

== Overview of Bell
The Bell programming language, as one can guess, is designed to learn from the "mistakes" and lessons of the past when it comes to #minecraft abstraction layers. It is also designed to be opinionated, and not necessarily easily to learn, but yet not too esoteric and hard to learn. Good documentation and tooling is a key part of the success of the programming language and it's primary implementation, as it's a core part of adoptability and usability. Bell also puts however explicitness, in performance and in general, alongside safety as core goals, in stark difference to MCfunction. Why bother? Aren't computers fast enough? Unfortunately, as the process of running MCfunction is very high-overhead, that isn't actually the case, especially when code must manipulate in-game entities and blocks. Before we continue on to the next few chapters of this article, covering Bell's design with more detail given to individual elements of it, we believe it would be useful to lay down the fundamental ideas and vision for Bell here, so that they may be used to understand the rest of this article. And so, in general: Bell is a dependently-typed, primarily functional programming language with algebraic effects and regionalized mutation. To better understand things, let's go over each term:

- Dependently-typed - In addition to types binding types (For example `Vec` binding `i32` to create the usable type `Vec<i32>`), types may also bind terms, to create types _depending_ on terms. For example, `Vec<i32, 3>` may mean the vector can only contain exactly 3 elements. In Rust for example, types such as `[T; const N: usize]` are dependently-typed.
- Primarily functional - High-level code is encouraged to be functional in nature. Not by necessarrily using recursion, but by using higher-order functions. Constructs scuh as iterators and a map function are encouraged. 
- Algebraic effects - Instead of functions simply causing side-effects, they must mark their effects in their signature. Effects are like exceptions from Java for instance, but more generalized. They need be like an error. Control can be returned to the context generating the effect.
- Regionalized mutation - Mutation and imperiative structures are allowed in the language, but they have to be regionalized, meaning they have to be contained in a given context (like a function). For example, one may implement the function `factorial` as:
  ```rust
  fn factorial(mut number: u32) -> u32 {
    let mut product = 1;
    
    while number <= 2 {
      product *= number;
      number -= 1;
    }
    
    product
  }
  ```
  even though that implementation uses mutation and imperiative control-flow, in supposed conflict to Bell's primarily functional design, because this "imperiative"-ness is confined to the function. Side-effects, like those caused by global variables, are impossible and code becomes easier to reason about.

In comparison to most programming languages reviewed here, but perhaps MCX, this feature-set makes Bell extremely beginner-unfriendly and complicated at first sight. Despite this, we believe this feature set makes Bell very well suited as a #minecraft abstraction layer, and that using gradual complexity, alongside familiar, imperiative syntax, this can be mitigated. It may also appear that this feature set would make Bell very slow to run, however in fact it is performance justifying some of these features. Again, let's go other each relevant feature and explain why this is the case.

- Dependent-typing - Most of it's overhead can generally be removed at compile-time, making it mostly a zero-cost abstraction. The reason for bothering in the first case is that dependent-typing provides more information to the compiler, allowing for more optimizations and safer code. For example, consider attempting to create an iterator over `[T; 7]` in Rust, and then `collect`-ing back to an array. In Rust doing this safely and concisely isn't easy, but in Bell this could be done safely, as the iterators would have actual knowledge about the length of the thing they are iterating over. Consider another example, of iterating over a zipping of three vectors, all of length `n`, in a dependently-typed language like so:
  ```rust
  fn iter_3(vector_1: Vec<i32, n>, vector_2: Vec<i32, n>, vector_3: Vec<i32, n>) {
    for (element_1, element_2, element_3) in /* Zipped version of the vectors */ {
      /* Do stuff */
    }
  }
  ```
  It could be turned into corresponding code:
  ```
  fn iter_3(vector_1: Vec<i32, n>, vector_2: Vec<i32, n>, vector_3: Vec<i32, n>) {
    let mut index = 0;
  
    while index < n {
      let (element_1, element_2, element_3) = (vec1[index], vec2[index], vec3[index]);
      /* Do stuff */
      index += 1;
    }
  }
  ```
  This code uses only a single comparison each iteration, instead of more, because it utilizes the information that the vectors' lengths are the same to avoid evaluating the same boolean expression twice. Because in #minecraft every operation could potentially take a lot of time, these kinds of optimizations are key.
- Functional programming - The reliance on higher-order functions can generally be eliminated using defunctionalization, saving on performance. Additionally, we believe higher-level code has less of a frequency to error, as humans are generally better at higher-level reasoning, obscuring specific details, in comparison to low-level reasonings involving often times too many details easy to forget. Indexing for example is discouraged to be done by hand in Bell, to avoid errors. Why? Because #minecraft worlds aren't easily recoverable - just like you shouldn't mess around in the file-system, you shouldn't mess around in a #minecraft world.
- An effect system - continuing Bell's emphasis on correctness we believe making effects explicit blocks out nasty bugs and makes sure changes to a #minecraft world happen in a controlled manner. At the most basic level, this is the case because effects cascade if you don't handle them, and so functions for example without the proper effect specifiers in their signature using said effects do not compile, ensuring the programmer is aware of any changes they are making in their world, or their players, entities and so on.

= Design guidelines and guiding principles
We believe that as seen in "The Principles of the Flix Programming Language", programming language principles should be motivated and clearly stated. Therefore, we have decied to briefly explain exactly what principles underly the design decisions you are about to dive into at large.

== Principle of least privliege
The first principle covered here of Bell, is that language semanatics and constructs should enforce the idea of _least privliege_ - the most restrictive semantics must be the default for language constructs. To ease the semantics one must manually specify so. For example, module members in Bell are by default private, and so can only be used inside the module, because this is the most restrictive visibility modifier one can put on an element. Likewise in Bell variables are by default immutable, as again this is the most restrictive form of usage one can place on a variable. The reason the principle of least privliege is integrated into the language is that it prevents problematic errors, that lay unnoticed for a long time. If you meant to employ less restrictive semantics, you may simply change the program, and your change will importantly be _additive_, you'll only unlock new things to do. If on the other hand you meant for example, for a function to be private instead of public, someone could use it in a manner unintended, and changing things means you'll face compatbility issues, among other problems. 

=== Err often
Supporting the princple of least privliege is the principle of erroring often - when a program behaves in a way unlikely to be intentional, the compiler will generally at least throw a warning, and for cases where this behavior is easily changeable, an error. This is because erroring often can take away time from the inexperienced programmer on the short-term, but save him time debugging and running his program in the long-term. Concerns about correctness outweight concerns about developer productivity, in most cases.

== Principle of least resistance
Borrowed from Physics terminology, the PoLR encourages designs which give the safest choice (most unlikely to cause bugs and errors) the shortest time to implement. In other words, safe choices shouldn't receive resistance from the language, and ideally very unsafe choices should receive such resistance, to encourage programmer reflection and possibly change of choice. For example, if one divides in a program without giving any thought to the fact that the division could fail (with a division by zero), they will have to annotate the function as one returning an effect representing the divsion by zero error, and then later annotate any other functions using said function without handling this effect the same. In this case as we can see, not handling the possible error in an explicit manner causes a list of rewrites in the program, making it easier to just handle the error.

== Principle of explicitness
The principle of explicitness states that non-trivial things in the language should have a similar run-time representation to their implied, compile-time API. In less general words, that language constructs need to be explicit, as to prevent needless confusion and alegedly spurious errors and to aid predictability, which helps against bugs and expected-actual performance mismatches. This manifests itself in a couple of ways.

=== Explicit semantics
Firstly, the semantics of the language should serve to be explicit and well and simply defined, so that code will be easy to understand and reason about, and performance be mostly intuitive. For example, Bell will not have a system for representing strings that would make them appear to be run-time manipulateable, when in practice they can only change at compile-time due to technical limitations. Such as system is of course, very much possible, as in #minecraft strings are most commonly found embedded directly in the commands that need them. Such is the case with the `tellraw` command for example. Likewise, relying on compile-time work to eliminate any such run-time string operations results in unreliable, or intuitive compilation that depends on the state of the language's optimization tooling. This is an example of the importance of having explicit semantics.

=== Explicit coercisions
Secondly, no type coercisions should be implicit in the language, as again this causes confusion that could lead to run-time bugs, and in cases where coercisions take valuable time, unpredictable performance.

== Principle of least surprise
Continuing from the PoE, the PoLS mainly exists to make sure the semantics of Bell are intuitive. Things should do what they appear to do following a short description, and unless given a good reason, semantics should be similar to those of other programming languages. For example, even if hypothetically indexing from 1 instead of 0 would be simpler for beginners to understand, it would still not be done, given this is something very few languages do and is thus a source of possible bugs and misunderstandings.

== Correctness
This is of course obvious, but Bell, due to it's ultimate role as a #minecraft abstraction layer and due to the reasons detailed above (like the lack of easy recoverability of #minecraft worlds), Bell puts great emphasis on correctness, even at the cost of developer productivity for example.

== Consistency and parallelity
Bell also sets for itself as a goal to be consistent in it's design and to make sure parallel features have parallel traits. Therefore, for example specifiying the type parameters of a record should be similar to specifying the parameters of a function. Consistency makes for a simpler language that's easier to learn.

== Principle of ease of access
Another principle of Bell is the PoEoA, which states that commonly used language constructs should be easier to use. For example, it could be the case that despite the fact that a printing function is in the `io` module of the standard library, it would still be included alongside that in the prelude, as this is a frequently used function. An anti-example of this is the way in which one prints to the standard output in Java, looking like a variation of `System.out.println` instead of the far simpler `println`.

== Familar and glanceable syntax
We believe syntax can aid quite a lot in making the language more accessible. Therefore Bell strives to have a familiar syntax that is based on curly braces, traditional function call syntax and so on, which also allows one to easily understand a programs structure at a glance. The main way this is done is via keywords, ideally short ones. Even when they aren't strictly needed, they can help make it clear what is going on.

= Type and effect system

= Module system

= Syntax

= CLI