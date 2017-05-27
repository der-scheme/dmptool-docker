production:
  rss:                    https://blog.dmptool.org/feed # Ignore this in branches forked from freiburg
  blog:                   http://blog.dmptool.org # Ignore this in branches forked from freiburg
  feedback_email_to:      ${DMPTOOL_FEEDBACK_EMAIL_TO}
  feedback_email_from:    no-reply@${HOSTNAME}
  recaptcha_public_key:
  recaptcha_private_key:
  google_analytics_key:
  google_analytics_host:
  host_for_email_links:   https://${HOSTNAME}
  ld_path_for_pandoc:     / # We probably don't need this.
  pdf_font:
    bold: Crimson-Bold.ttf
    italic: Crimson-Italic.ttf
    bold_italic: Crimson-BoldItalic.ttf
    normal: Crimson-Roman.ttf
  mailer_submission_default:
    subject: '[DMPTool] Your plan has been submitted for feedback'
    body: 'Hello [User Name], your DMP "[Plan Name]" has been submitted for feedback from an administrator at your institution.  If you have questions pertaining to this action, please contact us at http://www.cdlib.org/services/uc3/contact.html'
  contact_us_url: 'https://${HOSTNAME}/contact'
