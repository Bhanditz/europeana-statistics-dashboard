“I help/teach ________ (ideal client) to ________ (feature) so they can _________ (benefit).”

#### Setting up your Environment

* Install GIT
* Install RVM (http://rvm.io/)
* Install Ruby 2.1.0
* Install Rails '4.1.0'
* Install PostGreSQL 9.3.3. Create user with username: developer and password: developer

#### Important URLs

Install Ruby: https://www.digitalocean.com/community/articles/how-to-install-ruby-on-rails-on-ubuntu-12-04-lts-precise-pangolin-with-rvm

Install Rails: gem install rails

Install PostGreSQL: https://help.ubuntu.com/community/PostgreSQL

Configure PostGreSQL: http://www.pixelite.co.nz/article/installing-and-configuring-postgresql-91-ubuntu-1204-local-drupal-development

#### Common Commands

$ rvm list

$ ruby -v

$ rails -v

$ psql --version

#### Getting Started

$ git clone git@github.com:pykih/rumi.io.git

$ cd rumi.io

$ rake db:create

$ rake seed:setup

$ rails s

Open [http://localhost:3000](http://localhost:3000)






We help people understand their data

We help people SHARE their data

We help people operate their data

We connect users to data through useful and relevant interfaces

That's how we translate data into experiences 

That's how we tell stories from data


That's how we support new uses of data

Ultimately thats how we make sense of a world increasingly shaped by algorithms

The upcoming era of rich data will disrupt the way data is used

We are taking an active part in the revolution of Human Data Interactions

We connect users to data through digital interfaces:

web and mobile applications
software
editorial content
creative installations
We help people understand, operate and communicate their data.

We translate data into experiences, to share narratives, support new uses, and make sense of a world increasingly shaped by algorithms. We design useful, relevant interfaces through our workflow, which revolves around both data and user needs.

Our interfaces are a game changer, in that they introduce our clients to a strategy that makes the most out of data.

Our core competencies relate to data-driven strategies, information and interaction design, as well as data visualization.

Within Dataveyes, we share the firm conviction that the upcoming era of rich data and smart objects will disrupt the way data is conventionally used. Through our works, we take an active part in the revolution of Human-Data interactions.


VALIDATE

We invent a new visual language to translate data into information.
Through our visualizations, we empower our users, to decode and process complex datasets, in order to clarify concepts and support decision making.
INVOLVE

We enable users to take data into their hands and explore it.
Through advanced interactions, our visualizations help users make the stories their own, in a way that improves comprehension and memorization.
SURROUND

We focus the attention of user on what is valuable to them.
Our works can also take the form of more ambient experiences, which immerse users and unfold progressively before their eyes.
TRUST

We tirelessly fight against algorithm obscurantism.
Our works establish a relationship of trust with our users. Our interfaces are not impenetrable black boxes, they help understand the logic of the underlying algorithms.
ACCOMPANY

We extract more value from data to support and guide everyday actions.
Our interfaces grant users with a sense of responsibility in their daily environment, namely through advanced dashboards and connected objects.

Including Map charts when @gr's api is ready

Timeline,timeline-map,"Timeline map charts are similar to choropleth charts, in that they also use colour hues and saturation in order to represent values of a single dataset for several geographic locations. However, they allow one to construct a time lapse, dynamic view of how the data (for each region) changed over time",https://s3-ap-southeast-1.amazonaws.com/charts.pykih.com/icons/world-timeline.png,https://s3-ap-southeast-1.amazonaws.com/charts.pykih.com/icons/data.timeline.map.png,PykCharts.maps.timelineMap,2,Map Charts,TL,public/PykCharts/src/js/maps/maps.js,public/PykCharts/src/js/maps/oneLayer.js,"{""dimensions_required"":2,""metrics_required"":1,""dimensions_alias"":[""iso2"",""timestamp""],""metrics_alias"":[""size""]}"


Choropleth,one-layer-map,"Choropleth are map charts that use several colours or a single colour with various saturations in order to represent a data set over a geographical map. They provide a snapshot of how magnitude of data varies by geographic location, the magnitude of data being represented by the variation in saturation or hues of colours. Choropleth maps are best used when one wishes to provide a snapshot for a fixed/static moment in time",https://s3-ap-southeast-1.amazonaws.com/charts.pykih.com/icons/world-heat.png,https://s3-ap-southeast-1.amazonaws.com/charts.pykih.com/icons/data.map.png,PykCharts.maps.oneLayer,1,Map Charts,CH,public/PykCharts/src/js/maps/maps.js,public/PykCharts/src/js/maps/oneLayer.js,"{""dimensions_required"":1,""metrics_required"":1,""dimensions_alias"":[""iso2""],""metrics_alias"":[""size""]}"