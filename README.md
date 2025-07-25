# cookbook-druid-indexer
[![Build Status][build-shield]][build-url]
[![Linters][linters-shield]][linters-url]
[![License][license-shield]][license-url]

<!-- Badges -->
[build-shield]: https://github.com/redBorder/cookbook-druid-indexer/actions/workflows/rpm.yml/badge.svg?branch=master
[build-url]: https://github.com/redBorder/cookbook-druid-indexer/actions/workflows/rpm.yml?query=branch%3Amaster
[linters-shield]: https://github.com/redBorder/cookbook-druid-indexer/actions/workflows/lint.yml/badge.svg?event=push
[linters-url]: https://github.com/redBorder/cookbook-druid-indexer/actions/workflows/lint.yml
[license-shield]: https://img.shields.io/badge/license-AGPLv3-blue.svg
[license-url]: https://github.com/cookbook-druid-indexer/blob/HEAD/LICENSE

Chef cookbook to install and configure druid-indexer in redborder environments

### Platforms

- Rocky Linux 9

### Chef

- Chef 15.7.0 or later

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## Adding dimensions, exclusions or metrics for rb-druid-indexer

You can add/remove dimensions, dimensions exlusions or metrics for the datasource in the druid indexer by editting the **base_task** array on **cookbook-druid-indexer/resources/providers/config.rb**.

When chef-client is executed, this information will be put on **/etc/rb-druid-indexer/config.yml** for the indexer to use

## License

GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007
