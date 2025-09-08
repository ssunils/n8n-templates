# n8n-templates

This repository contains n8n workflow templates and MCP (Model Context Protocol) server configurations for various automation scenarios.

## 📁 Templates

### LinkedIn Jobs Automation
**Path**: `templates/linkedin-jobs-automation/`

A comprehensive automation solution for LinkedIn job hunting that includes:
- **Automated job discovery** with customizable search criteria
- **Real-time notifications** via Slack and Email
- **Application tracking** with status updates and interview scheduling
- **Daily analytics reports** with performance insights
- **Database storage** with comprehensive job data management

**Features:**
- ⏰ Scheduled job scraping every 4 hours
- 🔍 Smart filtering and deduplication
- 📊 Performance analytics and reporting
- 🗄️ PostgreSQL database integration
- 📱 Multi-channel notifications (Slack, Email)
- 📅 Calendar integration for interviews
- 🎯 Application success tracking

**Templates included:**
- `linkedin-job-search-alert.json` - Main job discovery workflow
- `job-storage-webhook.json` - Database storage endpoint
- `job-application-tracker.json` - Application status tracking
- `daily-analytics-report.json` - Analytics and reporting
- `database-schema.sql` - PostgreSQL database setup
- `config.json` - Configuration guide

[📖 View LinkedIn Jobs Documentation](templates/linkedin-jobs-automation/README.md)

## 🔧 MCP Servers

### n8n-mcp

A Model Context Protocol server for n8n workflow automation platform.

**Configuration:**
```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true"
      }
    }
  }
}
```

## 🚀 Installation

### MCP Server Setup
1. Copy the configuration from `claude_desktop_config.json` to your Claude Desktop configuration file
2. Restart Claude Desktop  
3. The n8n-mcp server will be available for use

### Template Usage
1. Choose a template from the `templates/` directory
2. Follow the specific README instructions for each template
3. Import the workflow JSON files into your n8n instance
4. Configure credentials and customize parameters
5. Test and activate the workflows

## 📚 Documentation

Each template includes comprehensive documentation:
- **Setup instructions** with prerequisites
- **Configuration guides** for customization
- **Troubleshooting tips** for common issues
- **Usage examples** and best practices
- **Database schemas** where applicable

## 🤝 Contributing

We welcome contributions to expand the template library!

### Adding New Templates
1. Create a new directory under `templates/`
2. Include all necessary workflow JSON files
3. Provide comprehensive README documentation
4. Add configuration examples and setup instructions
5. Test thoroughly before submitting

### Template Guidelines
- **Clear documentation** with step-by-step setup
- **Modular design** with reusable components
- **Error handling** and validation
- **Security best practices** for credentials
- **Performance considerations** for scalability

## 📄 License

This repository is provided under the MIT License. Individual templates may have additional usage guidelines - please refer to each template's documentation.

## ⚠️ Disclaimer

These templates are for educational and personal use. Please ensure compliance with third-party terms of service and applicable regulations. Always respect rate limits and use automation responsibly.

---

**Happy Automating! 🤖**
