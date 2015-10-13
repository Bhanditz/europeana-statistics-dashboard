#### Requirements

* Ruby 2.2.0
* Rails 4.1.0

### External Gem/Libraries which we use

* [ruby-jq][1]
* [sidekiq][2]
* [Pykcharts for charting library][3]

### Getting started with DB setup

* `rake ref:seed` - A rake tasks which helps in seeding the database.
    * It creates Accounts
    * It creates Project
    * It Seeds from csv files which are placed in ref folder
        * `reference charts`
        * `reference themes`
        * `country codes for maps`
        * `default db connection`
        * `default provider report template`
        * `reports from previous versions`

* For configuring the theme, we can visit [here][4] as a reference. After deciding the configuration, we can take the configuration object and place it in the ref/theme.csv file in the right format.
* We can change the configurations and then run the command `rake ref:seed` on the terminal. It will load the changes in the db.

[1]: https://github.com/winebarrel/ruby-jq
[2]: http://sidekiq.org/
[3]: http://pykcharts.com/
[4]: http://pykcharts.com/tour/pie