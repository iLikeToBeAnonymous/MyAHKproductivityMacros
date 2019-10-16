# MyAHKproductivityMacros

[Great Github workflow example](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow)
[Good github quick reference](https://rogerdudler.github.io/git-guide/)
[Using syntax highlighting in markdown syntax](https://github.com/github/linguist/blob/master/lib/linguist/languages.yml)  


<ul>
  <li> Make sure your local version matches the master branch before making a new branch</li>

  ```gitattributes
  git checkout master
  git fetch origin
  git reset --hard origin/master
  ```
  <li>Now make a new (local) branch</li>

  ```gitattributes
  git checkout -b new-feature
  ```
  <li>Once you've made changes and want to push them to the branch on Github</li>

  ```gitattributes
  git status
  git add <some-file>
  git commit
  ```
  <li>Once your changes have been committed, push those changes to a branch on Github</li>

  ```gitattributes
  git push -u origin new-feature
  ```
</ul>
