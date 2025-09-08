-- LinkedIn Jobs Automation Database Schema
-- PostgreSQL Database Setup

-- Create database (run this separately if needed)
-- CREATE DATABASE linkedin_jobs_db;

-- Create linkedin_jobs table
CREATE TABLE IF NOT EXISTS linkedin_jobs (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    company VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    summary TEXT,
    link TEXT,
    posted_date TIMESTAMP,
    scraped_at TIMESTAMP NOT NULL DEFAULT NOW(),
    keywords VARCHAR(500),
    search_location VARCHAR(255),
    job_hash VARCHAR(32) UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'applied', 'interview', 'rejected', 'offer', 'accepted')),
    is_applied BOOLEAN DEFAULT FALSE,
    is_saved BOOLEAN DEFAULT FALSE,
    application_date TIMESTAMP,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    notes TEXT,
    
    -- Indexes for better performance
    INDEX idx_linkedin_jobs_company (company),
    INDEX idx_linkedin_jobs_location (location),
    INDEX idx_linkedin_jobs_status (status),
    INDEX idx_linkedin_jobs_created_at (created_at),
    INDEX idx_linkedin_jobs_keywords (keywords),
    INDEX idx_linkedin_jobs_is_applied (is_applied),
    INDEX idx_linkedin_jobs_job_hash (job_hash)
);

-- Create job search queries table to track different search configurations
CREATE TABLE IF NOT EXISTS job_search_queries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    keywords VARCHAR(500) NOT NULL,
    location VARCHAR(255),
    experience_level VARCHAR(100),
    job_type VARCHAR(100),
    remote BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    last_run_at TIMESTAMP,
    total_jobs_found INTEGER DEFAULT 0,
    
    INDEX idx_job_search_queries_active (active),
    INDEX idx_job_search_queries_last_run_at (last_run_at)
);

-- Create job applications table for detailed tracking
CREATE TABLE IF NOT EXISTS job_applications (
    id SERIAL PRIMARY KEY,
    job_id VARCHAR(255) NOT NULL REFERENCES linkedin_jobs(id) ON DELETE CASCADE,
    applied_at TIMESTAMP NOT NULL DEFAULT NOW(),
    application_method VARCHAR(100), -- 'linkedin', 'company_website', 'email', etc.
    cover_letter_used BOOLEAN DEFAULT FALSE,
    resume_version VARCHAR(255),
    status VARCHAR(50) DEFAULT 'submitted' CHECK (status IN ('submitted', 'viewed', 'interview_requested', 'interview_scheduled', 'interview_completed', 'rejected', 'offer', 'accepted')),
    status_updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    interview_date TIMESTAMP,
    interview_type VARCHAR(100), -- 'phone', 'video', 'in_person', 'technical', etc.
    notes TEXT,
    feedback TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_job_applications_job_id (job_id),
    INDEX idx_job_applications_status (status),
    INDEX idx_job_applications_applied_at (applied_at)
);

-- Create contacts table for networking
CREATE TABLE IF NOT EXISTS job_contacts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    linkedin_profile TEXT,
    company VARCHAR(255),
    position VARCHAR(255),
    relationship VARCHAR(100), -- 'recruiter', 'hiring_manager', 'employee', 'referral', etc.
    notes TEXT,
    last_contact_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_job_contacts_company (company),
    INDEX idx_job_contacts_relationship (relationship),
    INDEX idx_job_contacts_email (email)
);

-- Create job_contact_interactions table
CREATE TABLE IF NOT EXISTS job_contact_interactions (
    id SERIAL PRIMARY KEY,
    contact_id INTEGER NOT NULL REFERENCES job_contacts(id) ON DELETE CASCADE,
    job_id VARCHAR(255) REFERENCES linkedin_jobs(id) ON DELETE SET NULL,
    interaction_type VARCHAR(100) NOT NULL, -- 'email', 'linkedin_message', 'phone', 'meeting', etc.
    subject VARCHAR(255),
    message TEXT,
    response_received BOOLEAN DEFAULT FALSE,
    interaction_date TIMESTAMP NOT NULL DEFAULT NOW(),
    notes TEXT,
    
    INDEX idx_job_contact_interactions_contact_id (contact_id),
    INDEX idx_job_contact_interactions_job_id (job_id),
    INDEX idx_job_contact_interactions_interaction_date (interaction_date)
);

-- Create analytics views for reporting
CREATE OR REPLACE VIEW job_search_analytics AS
SELECT 
    DATE(created_at) as search_date,
    COUNT(*) as jobs_found,
    COUNT(CASE WHEN is_applied THEN 1 END) as applications_sent,
    COUNT(CASE WHEN status = 'interview' THEN 1 END) as interviews_scheduled,
    COUNT(CASE WHEN status = 'offer' THEN 1 END) as offers_received,
    COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejections,
    ROUND(AVG(CASE WHEN is_applied THEN 1.0 ELSE 0.0 END) * 100, 2) as application_rate
FROM linkedin_jobs 
WHERE status != 'inactive'
GROUP BY DATE(created_at)
ORDER BY search_date DESC;

-- Create company performance view
CREATE OR REPLACE VIEW company_performance AS
SELECT 
    company,
    COUNT(*) as total_jobs,
    COUNT(CASE WHEN is_applied THEN 1 END) as applications_sent,
    COUNT(CASE WHEN status = 'interview' THEN 1 END) as interviews,
    COUNT(CASE WHEN status = 'offer' THEN 1 END) as offers,
    ROUND(COUNT(CASE WHEN is_applied THEN 1 END)::numeric / COUNT(*) * 100, 2) as application_rate,
    ROUND(COUNT(CASE WHEN status = 'interview' THEN 1 END)::numeric / NULLIF(COUNT(CASE WHEN is_applied THEN 1 END), 0) * 100, 2) as interview_rate
FROM linkedin_jobs 
WHERE status != 'inactive'
GROUP BY company
HAVING COUNT(*) >= 2  -- Only companies with 2+ jobs
ORDER BY total_jobs DESC, application_rate DESC;

-- Create keyword performance view
CREATE OR REPLACE VIEW keyword_performance AS
SELECT 
    keywords,
    COUNT(*) as total_jobs,
    COUNT(CASE WHEN is_applied THEN 1 END) as applications_sent,
    COUNT(CASE WHEN status = 'interview' THEN 1 END) as interviews,
    ROUND(COUNT(CASE WHEN is_applied THEN 1 END)::numeric / COUNT(*) * 100, 2) as success_rate,
    AVG(EXTRACT(EPOCH FROM (updated_at - created_at))/3600) as avg_response_time_hours
FROM linkedin_jobs 
WHERE status != 'inactive' AND keywords IS NOT NULL
GROUP BY keywords
ORDER BY total_jobs DESC, success_rate DESC;

-- Insert some sample search queries
INSERT INTO job_search_queries (name, keywords, location, experience_level, job_type, remote) VALUES
('Software Engineer SF', 'Software Engineer', 'San Francisco, CA', 'Mid-Senior level', 'Full-time', true),
('Frontend Developer Remote', 'Frontend Developer React', 'Remote', 'Mid-Senior level', 'Full-time', true),
('Data Scientist', 'Data Scientist Python', 'San Francisco, CA', 'Mid-Senior level', 'Full-time', false),
('DevOps Engineer', 'DevOps Engineer AWS', 'San Francisco, CA', 'Senior level', 'Full-time', true),
('Product Manager', 'Product Manager', 'San Francisco, CA', 'Mid-Senior level', 'Full-time', false);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_linkedin_jobs_updated_at BEFORE UPDATE ON linkedin_jobs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_search_queries_updated_at BEFORE UPDATE ON job_search_queries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_applications_updated_at BEFORE UPDATE ON job_applications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_contacts_updated_at BEFORE UPDATE ON job_contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function for job search statistics
CREATE OR REPLACE FUNCTION get_job_search_stats()
RETURNS TABLE(
    total_jobs BIGINT,
    jobs_today BIGINT,
    jobs_this_week BIGINT,
    total_applied BIGINT,
    interviews_scheduled BIGINT,
    offers_received BIGINT,
    rejections BIGINT,
    application_rate NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT as total_jobs,
        COUNT(CASE WHEN DATE(created_at) = CURRENT_DATE THEN 1 END)::BIGINT as jobs_today,
        COUNT(CASE WHEN created_at >= CURRENT_DATE - INTERVAL '7 days' THEN 1 END)::BIGINT as jobs_this_week,
        COUNT(CASE WHEN is_applied = true THEN 1 END)::BIGINT as total_applied,
        COUNT(CASE WHEN status = 'interview' THEN 1 END)::BIGINT as interviews_scheduled,
        COUNT(CASE WHEN status = 'offer' THEN 1 END)::BIGINT as offers_received,
        COUNT(CASE WHEN status = 'rejected' THEN 1 END)::BIGINT as rejections,
        ROUND(AVG(CASE WHEN is_applied = true THEN 1.0 ELSE 0.0 END) * 100, 2) as application_rate
    FROM linkedin_jobs
    WHERE status != 'inactive';
END;
$$ LANGUAGE plpgsql;

-- Example usage:
-- SELECT * FROM get_job_search_stats();
-- SELECT * FROM job_search_analytics LIMIT 7;
-- SELECT * FROM company_performance LIMIT 10;
-- SELECT * FROM keyword_performance LIMIT 5;
