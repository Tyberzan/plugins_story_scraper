# Discourse Buildnet Plugin

This plugin provides integration between Discourse and Buildnet, allowing for synchronization of topics and users.

## Features

- Automatically sync topics to Buildnet when created or edited
- Automatically sync users to Buildnet when created or updated
- Admin interface for managing the Buildnet integration
- Manual sync functionality for topics and users
- Detailed sync logs

## Installation

Follow the [Install a Plugin](https://meta.discourse.org/t/install-a-plugin/19157) guide, using 
`git clone https://github.com/discourse/discourse-buildnet.git` as the plugin command.

## Configuration

After installation, visit the plugin settings at Admin > Settings > Plugins > Buildnet.

Required settings:
- `buildnet_enabled`: Enable or disable the plugin
- `buildnet_api_url`: The URL of the Buildnet API
- `buildnet_api_key`: Your Buildnet API key

## Usage

Once configured, the plugin will automatically sync topics and users to Buildnet based on the events configured.

### Admin Interface

An admin interface is available at `/admin/buildnet` where you can:
- View sync logs
- Manually trigger syncs
- Test the connection to Buildnet

## Development

### Setup

```bash
cd /path/to/discourse/plugins
git clone https://github.com/discourse/discourse-buildnet.git
cd ../
bin/rails s
```

### Running Tests

```bash
bin/rake plugin:spec["discourse-buildnet"]
```

## License

MIT 