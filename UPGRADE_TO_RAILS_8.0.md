### Documentation of the Upgrade Process to Rails 8.0

1. **Check Ruby Version**: 
   - Ensure the Ruby version is at least 3.3.4. 
   - Check the current version with `ruby -v`. 
   - If necessary, install Ruby 3.3.4 using RVM or rbenv:
     - For RVM: `rvm install 3.3.4` and `rvm use 3.3.4 --default`.
     - For rbenv: `rbenv install 3.3.4` and `rbenv global 3.3.4`.

2. **Create a Feature Branch**: 
   - Before starting the upgrade, create a new feature branch to isolate changes:
     ```bash
     git checkout -b upgrade-rails-8.0
     ```

3. **Update Rails Gem**: 
   - Modify the Gemfile to specify the Rails version using if next?:
     ```ruby
     if next?(rails)
       gem rails, ~ next? to conditionally include gems based on the Ruby version:
     ```ruby
     if RUBY_VERSION >= 3.3.4
       gem some_gem
     end
     ```

5. **Run Tests**: 
   - After updating, run the test suite to identify any breaking changes or issues that need to be addressed.

6. **Review Release Notes**: 
   - Familiarize yourself with the new features and changes in Rails 8.0 by reviewing the official release notes and documentation.

7. **Address Potential Issues**: 
   - Be prepared to handle deprecated features and any changes in Rails conventions that may affect the application.

8. **Deployment**: 
   - If deploying, consider using Kamal 2 for a streamlined deployment process.

By following these steps, the upgrade to Rails 8.0 can be successfully completed while utilizing if next? blocks in the Gemfile to manage dependencies. Ensure that all changes are made on a feature branch and that tests are run to verify functionality.
