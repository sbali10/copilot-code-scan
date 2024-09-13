<#
.DESCRIPTION
    Script to send a notification email when a new version of AI generated code is sent to BlackDuck.
    To customize the recipients change the $SMTP_CONFIGURATION variable in the CI/CD settings.
#>

param (
    [Parameter(Mandatory=$true)][string]$SMTP_CONFIGURATION,
    [Parameter(Mandatory=$true)][string]$project_name
)

try {
    # Set the project version to the current date in the format dd.MM.yyyy
    $project_version = (Get-Date).ToString("dd.MM.yyyy")

    # Convert SMTP settings from string to JSON
    $SMTP_OBJECT = $SMTP_CONFIGURATION | ConvertFrom-Json

    # Create the SMTP client
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $smtp = New-Object Net.Mail.SmtpClient($SMTP_OBJECT.SMTP_SERVER)
    $smtp.Credentials = New-Object System.Net.NetworkCredential($SMTP_OBJECT.SMTP_USER, $SMTP_OBJECT.SMTP_PASS)
    $smtp.EnableSsl = $true

    # Create the email message
    $message = New-Object System.Net.Mail.MailMessage
    $message.From = New-Object System.Net.Mail.MailAddress($SMTP_OBJECT.SMTP_SENDER)
    ForEach ($mail in $SMTP_OBJECT.SMTP_RECIPIENTS.Split(",")) {
        $message.To.Add($mail)
    }
    $message.IsBodyHtml = $true

    # Set improved subject
    $message.Subject = "[$project_name] AI-generated code version $project_version sent to BlackDuck for review"

    # Set email body
    $message.Body = @"
<html lang="en">
<head>
    <meta charset="UTF-8">
</head>
<body>
    <p>A new version "$project_version" of AI-generated code for the project "$project_name" has been submitted to BlackDuck for analysis. Please review and send us the review report.</p>
</body>
</html>
"@

    # Send the email
    $smtp.Send($message)
} catch {
    Write-Error "Failed to send email: $_"
}