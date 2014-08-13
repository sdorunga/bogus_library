To set up the project just do:

```
git clone git@github.com:sdorunga1/bogus_library.git
cd bogus_library
bundle install
```

To run the specs, just run
`bundle exec rspec`

To see the test coverage run
`COVERAGE=true bundle exec rspec`

If you want to run the mutation tests, you can run one of the following lines
depending on which class you want to test

```
bundle exec mutant --require ./bogus_library --use rspec Library
bundle exec mutant --require ./bogus_library --use rspec LibraryCard
bundle exec mutant --require ./bogus_library --use rspec User
```
