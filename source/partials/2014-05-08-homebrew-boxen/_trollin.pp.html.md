```puppet
class projects::trollin {
  include icu4c
  include phantomjs

  boxen::project { 'trollin':
    dotenv        => true,
    elasticsearch => true,
    mysql         => true,
    nginx         => true,
    redis         => true,
    ruby          => '1.9.3',
    source        => 'boxen/trollin'
  }
}
```
