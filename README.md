
# Europeana Statistics Dashboard

[![security](https://hakiri.io/github/europeana/europeana-statistics-dashboard/master.svg)](https://hakiri.io/github/europeana/europeana-statistics-dashboard/master) [![Dependency Status](https://gemnasium.com/europeana/europeana-statistics-dashboard.svg)](https://gemnasium.com/europeana/europeana-statistics-dashboard)

## License

Licensed under the EUPL V.1.1. For full details, see [LICENSE.md](LICENSE.md).

## Requirements

* Ruby 2.3.1
* PostgreSQL *with support for the extensions enabled in [db/schema.rb](db/schema.rb)*
* Redis
* [Europeana Statistics Grape API][1]

## Getting started

1. Create config files. Samples for various deployment environments can be
  found in the [deploy/](deploy/) directory.
  * `config/redis.yml`
2. Set environment varialbes. In dev, these can go in `.env` (see [dotenv][2]).
  * `BASE_URL`: URL of this application once deployed
  * `REST_API_ENDPOINT`: URL of the [Europeana Statistics Grape API][1]
  * `EUROPEANA_API_URL`: Europeana API url
  * `WSKEY`: Europeana API wskey
  * `EUROPEANA_STYLEGUIDE_ASSET_HOST`: Where the sytleguide is to be loaded from
  * `AGGREGATOR_QUEUE_LIMIT`: A limit for how many aggregations will be retried when the requeu worker is ran
  * `GA_CLIENT_SECRET`: Google Secret
  * `GA_CLIENT_ID`: Google Client ID
  * `GA_SCOPE`: Google Scope
  * `GA_REFRESH_TOKEN`: Google Refresh Token
  * `GA_IDS`: Google Ids
  * `BASE_URL`: Base url for the app
  * `PORT`: port for the web app to run on
2. Run `bundle exec rake db:setup`
3. Optionally run tasks to populate the aggregations:
  * `bundle exec rake scheduled_jobs:create_countries`
  * `bundle exec rake scheduled_jobs:create_providers`
  * `bundle exec rake scheduled_jobs:create_data_providers`
  
  *Note that these tasks create ALL respective entries fetched from the Europeana API,
  it may take a long time to fully create all reports for all entries.
  
4. Start app
  * On production env, use the Procfile to start all app instances
  * On dev, run `foreman start`

## Login

1. Open the app in a web browser
2. Login as user "europeana_user", password "Europeana123!@#"
3. Edit your account and change your password at `/accounts/edit.europeana_user`


## Contributors
[Pykih Software LLP](https://pykih.com/)

[1]: https://github.com/europeana/europeana-statistics-grape
[2]: https://github.com/bkeepers/dotenv

