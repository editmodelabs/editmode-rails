# Filing an issue
Please visit  [Editmode Community Hub](https://hub.editmode.com/c/editmode-rails) to file an issue.

When filing an issue, please provide these details:
- A comprehensive list of steps to reproduce the issue.
- What you're expecting to happen compared with what's actually happening.
- Your application's complete Gemfile.lock, and Gemfile.lock as text in a Gist (not as an image)
- Any relevant stack traces ("Full trace" preferred)

# Pull requests
We gladly accept pull requests to add documentation, fix bugs and, in some circumstances, add new features to Editmode.

Here's a quick guide:
- Fork the repo.
- Run the tests. We only take pull requests with passing tests, and it's great to know that you have a clean slate.
- Create new branch then make changes and add tests for your changes. Only refactoring and documentation changes require no new tests. If you are adding functionality or fixing a bug, we need tests!
- Push to your fork and submit a pull request.

# Testing
#### Run
```
bundle install
rake
```