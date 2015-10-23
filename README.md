# Europeana Statistics Dashboard

## License

Licensed under the EUPL V.1.1. For full details, see [LICENSE.md](LICENSE.md).


## Requirements

* Ruby 2.2.2
* PostgreSQL *with support for the hstore extension*
* Redis
* [Europeana Statistics Grape API][1]

## Getting started

1. Create config files. Samples for various deployment environments can be
  found in the [deploy/](deploy/) directory.
  * `config/database.yml`
    * only PostgreSQL is supported
  * `config/redis.yml`
2. Set environment varialbes. In dev, these can go in `.env` (see [dotenv][2]).
  * `BASE_URL`: URL of this application once deployed
  * `REST_API_ENDPOINT`: URL of the [Europeana Statistics Grape API][1]
2. Run `bundle exec rake ref:seed`
3. Start app
  * On production env, use the Procfile to start all app instances
  * On dev, run `foreman start`

## Login

1. Open the app in a web browser
2. Login as user "europeana_user", password "Europeana123!@#"
3. Edit your account and change your password at `/accounts/edit.europeana_user`

## Seeding the database

`bundle exec rake ref:seed` runs a Rake task that helps in seeding the database.

* It creates Accounts
* It creates Project
* It Seeds from csv files which are placed in ref folder
    * `reference charts`
    * `reference themes`
    * `country codes for maps`
    * `default db connection`
    * `default provider report template`
    * `reports from previous versions`

* We can change the configuration and then re-run the Rake task, which will
load the changes to the db.

## Theme

To configure the theme, see [PykCharts.js][3] as a reference. After deciding the
configuration, place it in the file [ref/theme.csv](ref/theme.csv).

[1]: https://github.com/europeana/europeana-statistics-grape
[2]: https://github.com/bkeepers/dotenv
[3]: http://pykcharts.com/tour/pie 
