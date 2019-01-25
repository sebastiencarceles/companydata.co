# README

## Why open source?

I started this side project to provide company data through an easy-to-use API.

Unfortunately, the application was not lucrative enough to pay for the server charges (Elasticsearch as a service and Amazon RDS in particular), so I had to interrupt it.

However, I have decided to open source it, so it could help others:

* to read large files stored on Amazon S3 to import large data set in a local database
* to read open data from INSEE (with the [insee.rake](lib/tasks/insee.rake) tasks), KBO (with the [kbo.rake](lib/tasks/kbo.rake) tasks), Infogreffe (with the [infogreffe.rake](lib/tasks/infogreffe.rake) tasks), SIRENE (with the [sirene.rake](lib/tasks/sirene.rake) tasks)
* to calculate and check a VAT number in Europe => see the [vat.rb](app/models/vat.rb) model
* to use [Searchkick](https://github.com/ankane/searchkick) (an Elasticsearch gem) to request large data sets
* to have different representations for the same resource (using Active Model Serializers)
* to scrap data from sites that need authentication, like LinkedIn (warning: this is unauthorized by the terms of service) => see the task [scrap.rake](lib/tasks/scrap.rake) which uses the [LinkedinScrapper](app/business/linkedin_scrapper.rb)
* to dump large data sets to Yaml files and to load large data sets from Yaml files => see the [DataYaml module](lib/data_yaml.rb) and the [data.rake](lib/tasks/data.rake) tasks
* to manage subscriptions and billing with [ProAbono](http://proabono.com/)
* to use [RapidRailsThemes](https://rapidrailsthemes.com/)

## Data sets and useful links

### Belgium

[Banque-Carrefour des Entreprises](https://economie.fgov.be/fr/themes/entreprises/banque-carrefour-des/services-pour-tous/banque-carrefour-des-2)

### France

* [Base SIRENE des entreprises](https://www.data.gouv.fr/fr/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret/)
* [Infogreffe](https://opendata-infogreffe.com/explore/?sort=modified)
* [Base Adresses Nationale](https://adresse.data.gouv.fr/)
* [Registre National du Commerce et des Sociétés - INPI](https://www.inpi.fr/fr/licence-registre-national-du-commerce-et-des-societes-rncs)

### Europe

* [Online VAT check service from the European Commission](http://ec.europa.eu/taxation_customs/vies/vieshome.do?selectedLanguage=fr)

### Rest of the world

* [Opencorporates](https://opencorporates.com/)

## Contact

Feel free to contact me: sebastien dot carceles at gmail dot com.

# Previous README

Get started with this guide.

## Ruby version

Be sure to have Ruby 2.4.0 installed.

For example with `rbenv`:

```
cd path/to/project
rbenv install 2.4.0
rbenv local 2.4.0
```

## System dependencies

### Postgresql 10+

For Mac OS X:
* use the Postgres.app
* check the documentation to add commands to path

### Redis

For Mac OS X, with Brew:

```
brew install redis
brew services start redis
```

### Elasticsearch

For Mac OS X, with Brew:

```
brew cask install homebrew/cask-versions/java8
brew install elasticsearch
brew services start elasticsearch
```

### Heroku CLI

If you plan to deploy, you need Heroku CLI. For Mac OS X, with Brew:

```
brew install heroku/brew/heroku
heroku login
```

And use your credentials to log in.

## Application dependencies

### application.yml

Ask for the config file `application.yml` to the CTO and add it to the `config` directory.

### RapidRailsThemes

Run this command for RapidRailsThemes:

```
bundle config gems.rapidrailsthemes.com RRTemail:RRTpassword
```

### Bundle

```
bundle install
```

## Database creation and initialization

```
rails db:setup
```

## Tests

```
rspec
```

## Deployment

### Staging

The first time, add the remote:

```
heroku git:remote --remote staging -a company-io-staging
```

Then deploy:

```
git push staging
```

### Production

The first time, add the remote:

```
heroku git:remote --remote prod -a company-io
```

Then deploy:

```
git push prod
```
