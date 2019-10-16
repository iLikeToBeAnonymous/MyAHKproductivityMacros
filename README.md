# MyAHKproductivityMacros

[Great Github workflow example](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow)

[Good github quick reference](https://rogerdudler.github.io/git-guide/)

[Using syntax highlighting in markdown syntax](https://github.com/github/linguist/blob/master/lib/linguist/languages.yml)  



- Make sure your local version matches the master branch before making a new branch. If you're not already on the main branch, it'll switch to the main when you do this.

  ```gitattributes
  git checkout master
  git fetch origin
  git reset --hard origin/master
  ```
- Now make a new (local) branch. You don't have to create a branch ahead of time on Github.

  ```gitattributes
  git checkout -b new-feature
  ```
- Once you've made changes and want to push them to the branch on Github, you must first prep for the push.

  ```gitattributes
  git status
  git add <some-file>
  git commit
  ```
  
  <dl>
    <dt>At this stage, you'll be prompted to enter a description for the changes you've made. Type your description, then</dt>
      <dd>"Ctrl+O" to say it's finalized</dd>
      <dd>"Enter"</dd>
      <dd>"Ctrl+X" to exit the shell text editor and continue on your merry way</dd>
  </dl>

- Once your changes have been committed, push those changes to a branch on Github.

  ```gitattributes
  git push -u origin new-feature
  ```
