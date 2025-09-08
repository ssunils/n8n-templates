# LinkedIn Jobs Automation Template

A comprehensive n8n workflow template for automating LinkedIn job search, application tracking, and analytics reporting.

## 📋 Overview

This template provides a complete automation solution for LinkedIn job hunting, including:

- **Automated Job Discovery**: Scrape LinkedIn job postings every 4 hours
- **Smart Notifications**: Get instant alerts via Slack and Email for new opportunities
- **Application Tracking**: Track your job applications and interview progress
- **Daily Analytics**: Receive detailed performance reports and insights
- **Database Storage**: Store all job data with comprehensive analytics

## 🚀 Features

### 1. Job Search & Alerts (`linkedin-job-search-alert.json`)
- **Scheduled scraping** of LinkedIn job postings every 4 hours
- **Customizable search parameters** (keywords, location, experience level)
- **Automatic deduplication** and data validation
- **Real-time notifications** via Slack and Email
- **Database storage** for all discovered jobs

### 2. Database Storage Webhook (`job-storage-webhook.json`)
- **RESTful API endpoint** for storing job data
- **Data validation and enrichment** with metadata
- **Duplicate prevention** using job hashing
- **PostgreSQL integration** with full ACID compliance

### 3. Application Tracking (`job-application-tracker.json`)
- **Status updates** for job applications (applied, interview, offer, rejected)
- **Automatic notifications** for status changes
- **Calendar integration** for interview scheduling
- **Progress tracking** with detailed analytics

### 4. Daily Analytics Report (`daily-analytics-report.json`)
- **Comprehensive statistics** on job search performance
- **Company and keyword performance analysis**
- **Automated insights** and recommendations
- **Beautiful HTML email reports** and Slack summaries

## 🛠 Setup Instructions

### Prerequisites

1. **n8n Installation**: Running n8n instance (cloud or self-hosted)
2. **PostgreSQL Database**: For job data storage
3. **Slack Workspace**: For notifications (optional)
4. **Email Service**: SMTP or service provider for email notifications
5. **Google Calendar**: For interview scheduling (optional)

### Database Setup

1. **Create Database**:
   ```sql
   CREATE DATABASE linkedin_jobs_db;
   ```

2. **Run Schema Script**:
   ```bash
   psql -d linkedin_jobs_db -f database-schema.sql
   ```

3. **Configure n8n Database Connection**:
   - Create PostgreSQL credential in n8n
   - Use connection details from your database

### Workflow Installation

1. **Import Workflows**:
   - Import each JSON file into your n8n instance
   - Configure credentials for each service (PostgreSQL, Slack, Email, etc.)

2. **Configure Parameters**:
   
   **Job Search Parameters** (in `linkedin-job-search-alert.json`):
   ```javascript
   {
     "keywords": "Software Engineer",
     "location": "San Francisco, CA",
     "experience_level": "Mid-Senior level",
     "job_type": "Full-time",
     "remote": "true"
   }
   ```

3. **Set Up Credentials**:
   
   **PostgreSQL Database**:
   - Host: Your database host
   - Database: `linkedin_jobs_db`
   - User: Your database user
   - Password: Your database password

   **Slack Integration**:
   - Create Slack OAuth app
   - Configure bot permissions: `chat:write`, `channels:read`
   - Add bot to your channels

   **Email Service**:
   - Configure SMTP settings or email service API
   - Set sender and recipient addresses

### Webhook Configuration

1. **Update Webhook URLs**:
   - Replace `http://your-n8n-instance.com` with your actual n8n URL
   - Update authentication headers as needed

2. **Test Webhooks**:
   ```bash
   # Test job storage webhook
   curl -X POST http://your-n8n-instance.com/webhook/job-storage \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer YOUR_TOKEN" \
        -d '{
          "id": "test-job-1",
          "title": "Test Job",
          "company": "Test Company",
          "location": "Test Location"
        }'
   ```

## 📊 Usage

### Activating Workflows

1. **Start with Storage Webhook**: Activate `job-storage-webhook.json` first
2. **Enable Job Search**: Activate `linkedin-job-search-alert.json` 
3. **Add Analytics**: Activate `daily-analytics-report.json`
4. **Optional Tracking**: Activate `job-application-tracker.json` for manual updates

### Manual Application Updates

Send POST request to update application status:
```bash
curl -X POST http://your-n8n-instance.com/webhook/job-application-update \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -d '{
       "job_id": "job-12345",
       "status": "applied",
       "notes": "Applied through company website",
       "priority": "high"
     }'
```

### Viewing Analytics

**Database Queries**:
```sql
-- Get recent job search stats
SELECT * FROM get_job_search_stats();

-- View company performance
SELECT * FROM company_performance LIMIT 10;

-- Check keyword effectiveness
SELECT * FROM keyword_performance LIMIT 5;

-- Recent jobs
SELECT title, company, location, created_at, status 
FROM linkedin_jobs 
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY created_at DESC;
```

## 🔧 Customization

### Search Parameters

Modify the search parameters in `linkedin-job-search-alert.json`:

```javascript
// In the "Set Job Search Parameters" node
{
  "keywords": "Your Job Title",
  "location": "Your Location",
  "experience_level": "Entry level|Mid-Senior level|Director",
  "job_type": "Full-time|Part-time|Contract|Temporary|Internship",
  "remote": "true|false"
}
```

### Notification Channels

**Slack Configuration**:
```javascript
// Update channel ID in Slack nodes
"channelId": "C1234567890"  // Your Slack channel ID
```

**Email Recipients**:
```javascript
// Update email addresses
"toEmail": "your-email@company.com"
"fromEmail": "job-alerts@company.com"
```

### Scheduling

**Job Search Frequency**:
```javascript
// In Schedule Trigger node - every 4 hours
"rule": {
  "interval": [{"field": "hours", "hoursInterval": 4}]
}

// Alternative: Every 2 hours
"rule": {
  "interval": [{"field": "hours", "hoursInterval": 2}]
}
```

**Analytics Report Time**:
```javascript
// Daily at 9 AM
"rule": {
  "interval": [{"field": "cronExpression", "cronExpression": "0 9 * * *"}]
}
```

## 📈 Analytics & Reporting

### Key Metrics Tracked

- **Job Discovery**: Total jobs, new jobs today/this week
- **Application Rate**: Percentage of jobs you apply to
- **Response Rate**: Interview requests vs applications
- **Success Rate**: Offers vs applications
- **Company Performance**: Which companies have the most opportunities
- **Keyword Effectiveness**: Which search terms yield best results

### Report Contents

**Daily Analytics Include**:
- Job discovery summary
- Application pipeline status
- Top companies by job count
- Keyword performance analysis
- Automated insights and recommendations

## 🔒 Security & Privacy

### Data Protection
- All job data stored in your private database
- No data shared with third parties
- Encrypted database connections recommended
- Webhook authentication required

### Rate Limiting
- Built-in delays between requests to respect LinkedIn's terms
- Error handling for rate limit responses
- Automatic retry logic with exponential backoff

## 🐛 Troubleshooting

### Common Issues

**LinkedIn Scraping Fails**:
- Check if LinkedIn changed their HTML structure
- Update CSS selectors in the parsing code
- Verify User-Agent headers are still valid

**Database Connection Errors**:
- Verify PostgreSQL credentials
- Check database server accessibility
- Ensure database and tables exist

**Webhook Not Receiving Data**:
- Check n8n webhook URL accessibility
- Verify authentication headers
- Test with curl commands

**Notifications Not Sent**:
- Verify Slack bot permissions
- Check email SMTP settings
- Confirm channel/recipient addresses

### Debugging Tips

1. **Enable Debug Mode**: Turn on workflow debug logging
2. **Test Individual Nodes**: Use manual execution to test each step
3. **Check Logs**: Monitor n8n execution logs for errors
4. **Validate Data**: Use console.log in Code nodes for debugging

## 🔄 Updates & Maintenance

### Regular Maintenance

**Weekly**:
- Review job search effectiveness
- Update search keywords if needed
- Clean up old/irrelevant job data

**Monthly**:
- Analyze application success rates
- Optimize search parameters
- Review and update automation rules

**As Needed**:
- Update LinkedIn selectors if structure changes
- Refresh authentication tokens
- Backup database regularly

## 📚 Additional Resources

### LinkedIn Job Search API Alternatives
- [RapidAPI LinkedIn Jobs](https://rapidapi.com/hub)
- [SerpAPI LinkedIn Jobs](https://serpapi.com/linkedin-jobs-api)
- [JobSearch API](https://jobsearch.dev/)

### n8n Documentation
- [n8n Workflows](https://docs.n8n.io/workflows/)
- [HTTP Request Node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest/)
- [Webhook Node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/)
- [Schedule Trigger](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger/)

## 🤝 Contributing

We welcome contributions to improve these templates!

### How to Contribute
1. Fork the repository
2. Create a feature branch
3. Test your improvements thoroughly
4. Submit a pull request with detailed description

### Areas for Improvement
- Enhanced LinkedIn parsing for different job layouts
- Additional notification channels (Discord, Microsoft Teams)
- Machine learning for job recommendation scoring
- Integration with ATS systems
- Mobile-friendly dashboard

## 📄 License

This template is provided under the MIT License. See LICENSE file for details.

## ⚠️ Disclaimer

This automation tool is for educational and personal use only. Please ensure compliance with LinkedIn's Terms of Service and robots.txt file. The authors are not responsible for any violations of third-party terms of service.

**Important Notes**:
- Respect LinkedIn's rate limits and terms of service
- Use responsibly and ethically
- Consider LinkedIn Premium or official APIs for commercial use
- Always review and comply with local data protection regulations

---

**Happy Job Hunting! 🎯**

For questions, issues, or contributions, please open an issue in the repository.
