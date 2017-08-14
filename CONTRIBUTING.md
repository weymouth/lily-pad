### Contributing

Soon enough you will probably want to do something which isn't coded up yet. 

Great! This is an active and growing project and we love seeing how people are using it. And as you contribute, don't worry too much about making a mistake or putting up ugly code. We can always fix/clean it. Even better, we can suggest how you can fix/clean it yourself. 

If you have never contributed to a github repository, look through this [introduction page](https://guides.github.com/activities/forking/).

### Issues

As you start developing your own tests with LilyPad, you'll certainly run into a few walls. Try to write a [minimum working example](http://stackoverflow.com/help/mcve). In most cases, simply boiling a problem down to the bare minimum will help you figure it out yourself. If that doesn't work, [raise an issue](https://help.github.com/articles/creating-an-issue/) including your example and we'll try to help.


### Best practises

The basic guideline is to add code which is general and friendly enough to be useful for other users. This means: 
  * Creating and pushing test case files (such as `BlindFish.pde`) is especially useful since it gives everyone a chance to run and play with a new test case out-of-the-box!
  * Let users run your code through *high-level* interfaces, and only dig down into the guts of the methods if they choose.
  * Reuse as much existing code as possible. i.e. add a new capability by making a new class which *extends* a current class.
  * If you change low level routines, do so in a way which does not break compatibility. i.e. trigger your change with an *optional* argument.
  * Completely document and test all changes. 
  * Add a minimum working example at the top of any new files.

Good luck!
