# aidir
###### Am I Doing It Right

#### Description
aidir gem displays [Flog](https://github.com/seattlerb/flog) score differences
* between current git branch and origin/master
* of every method and file that got a different Flog score
* in a [color-coded](#score-colors) table

#### Install
```
gem install aidir
```

#### Usage
1. Change some ruby code on a branch other than master
2. Commit your local changes
3. Run aidir
```
$ aidir
```
4. Read the results.
5. Love/hate yourself more
6. Reward/improve yourself

#### Colorless example of results

###### Method scores

 Diff from master | Current | Method
 ---------------- | ------- | -------------------
             -9.3 |    17.7 | Foo#improved_method
              3.0 |    23.0 | Foo#worsened_method

###### File flog total scores

 Diff from master | Current | File
 ---------------- | ------- | -------------------
             -6.3 |   234.0 | app/models/foo.rb

###### File flog/method average scores

 Diff from master | Current | File
 ---------------- | ------- | -------------------
             -2.0 |    16.4 | app/models/foo.rb

#### Score colors
Difference from master:
* < 0: good, green
* 0 - 20: smells, yellow
* > 20: bad, red

Per-method score:
* 0 - 20: good, green
* 20 - 40: smells, yellow
* > 40: bad, red

#### Badgers
[![Code Climate](https://codeclimate.com/github/adomas-s/aidir.png)](https://codeclimate.com/github/adomas-s/aidir)

![Badger](http://upload.wikimedia.org/wikipedia/commons/4/41/Badger%28UO%29.jpg)
