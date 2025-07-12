#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');

// Configuration
const CONFIG = {
    PR_NUMBER: process.env.PR_NUMBER || null,
    POLL_INTERVAL: 5 * 60 * 1000, // 5 minutes in milliseconds
    MAX_RETRIES: 3,
    LOG_FILE: './pr-status.log'
};

// Logging utility
function log(message) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${message}\n`;
    console.log(logMessage.trim());
    fs.appendFileSync(CONFIG.LOG_FILE, logMessage);
}

// Execute shell command with error handling
function executeCommand(command) {
    try {
        const result = execSync(command, { 
            encoding: 'utf8',
            stdio: ['pipe', 'pipe', 'pipe']
        });
        return { success: true, output: result.trim() };
    } catch (error) {
        return { 
            success: false, 
            error: error.message,
            output: error.stdout ? error.stdout.trim() : '',
            stderr: error.stderr ? error.stderr.trim() : ''
        };
    }
}

// Check if PR has auto-merge enabled
function checkAutoMerge(prNumber) {
    log(`Checking auto-merge status for PR #${prNumber}`);
    const command = `mise exec -- gh pr view ${prNumber} --json autoMergeRequest`;
    const result = executeCommand(command);
    
    if (!result.success) {
        log(`Error checking auto-merge: ${result.error}`);
        return false;
    }
    
    try {
        const prData = JSON.parse(result.output);
        const autoMergeEnabled = prData.autoMergeRequest !== null;
        log(`Auto-merge enabled: ${autoMergeEnabled}`);
        return autoMergeEnabled;
    } catch (error) {
        log(`Error parsing auto-merge data: ${error.message}`);
        return false;
    }
}

// Query CI status for PR
function queryPRStatus(prNumber) {
    log(`Querying CI status for PR #${prNumber}`);
    const command = `mise exec -- gh run list --pr ${prNumber} --json status,conclusion,workflowName`;
    const result = executeCommand(command);
    
    if (!result.success) {
        log(`Error querying PR status: ${result.error}`);
        return { success: false, error: result.error };
    }
    
    try {
        const runs = JSON.parse(result.output);
        log(`Found ${runs.length} workflow runs`);
        
        if (runs.length === 0) {
            log('No CI runs found for this PR');
            return { success: true, allPassed: true, runs: [] };
        }
        
        const failedRuns = runs.filter(run => 
            run.conclusion === 'failure' || run.conclusion === 'cancelled'
        );
        
        const pendingRuns = runs.filter(run => 
            run.status === 'in_progress' || run.status === 'queued'
        );
        
        const successRuns = runs.filter(run => 
            run.conclusion === 'success'
        );
        
        log(`Status summary: ${successRuns.length} successful, ${failedRuns.length} failed, ${pendingRuns.length} pending`);
        
        const allPassed = failedRuns.length === 0 && pendingRuns.length === 0;
        const hasFailed = failedRuns.length > 0;
        
        return {
            success: true,
            allPassed,
            hasFailed,
            runs: {
                total: runs.length,
                successful: successRuns.length,
                failed: failedRuns.length,
                pending: pendingRuns.length,
                failedRuns: failedRuns.map(r => r.workflowName)
            }
        };
    } catch (error) {
        log(`Error parsing CI status: ${error.message}`);
        return { success: false, error: error.message };
    }
}

// Handle CI failures
function handleFailures(statusResult) {
    log('⚠️  CI FAILURES DETECTED');
    log(`Failed workflows: ${statusResult.runs.failedRuns.join(', ')}`);
    
    // Send notification (you can customize this)
    const notificationCommand = `mise exec -- gh pr comment ${CONFIG.PR_NUMBER} --body "❌ CI failures detected in workflows: ${statusResult.runs.failedRuns.join(', ')}"`;
    const notifyResult = executeCommand(notificationCommand);
    
    if (notifyResult.success) {
        log('Failure notification sent to PR');
    } else {
        log(`Failed to send notification: ${notifyResult.error}`);
    }
    
    // Exit with error code
    process.exit(1);
}

// Handle successful completion
function handleSuccess() {
    log('✅ All CI checks passed and auto-merge is enabled');
    log('PR is ready for auto-merge - exiting polling');
    
    // Optional: Add success comment
    const successCommand = `mise exec -- gh pr comment ${CONFIG.PR_NUMBER} --body "✅ All CI checks passed! Auto-merge will proceed."`;
    executeCommand(successCommand);
    
    process.exit(0);
}

// Main polling function
function pollPRStatus() {
    if (!CONFIG.PR_NUMBER) {
        log('❌ PR_NUMBER environment variable not set');
        process.exit(1);
    }
    
    log(`Starting PR status poll for PR #${CONFIG.PR_NUMBER}`);
    
    // Check CI status
    const statusResult = queryPRStatus(CONFIG.PR_NUMBER);
    
    if (!statusResult.success) {
        log(`Failed to query PR status: ${statusResult.error}`);
        return; // Continue polling
    }
    
    // Handle failures
    if (statusResult.hasFailed) {
        handleFailures(statusResult);
        return;
    }
    
    // Check if all checks passed
    if (statusResult.allPassed) {
        log('All CI checks passed');
        
        // Check if auto-merge is enabled
        const autoMergeEnabled = checkAutoMerge(CONFIG.PR_NUMBER);
        
        if (autoMergeEnabled) {
            handleSuccess();
            return;
        } else {
            log('Auto-merge not enabled - continuing to poll');
        }
    } else {
        log('CI checks still pending - continuing to poll');
    }
    
    log(`Next poll in ${CONFIG.POLL_INTERVAL / 1000} seconds`);
}

// Signal handling for graceful shutdown
process.on('SIGINT', () => {
    log('Received SIGINT - shutting down gracefully');
    process.exit(0);
});

process.on('SIGTERM', () => {
    log('Received SIGTERM - shutting down gracefully');
    process.exit(0);
});

// Start polling
log('PR Status Polling Service Started');
log(`Configuration: PR #${CONFIG.PR_NUMBER}, Poll interval: ${CONFIG.POLL_INTERVAL / 1000}s`);

// Initial poll
pollPRStatus();

// Set up interval polling
setInterval(pollPRStatus, CONFIG.POLL_INTERVAL);
